package com.library.service;

import com.library.entity.Book;
import com.library.entity.Borrow;
import com.library.entity.User;
import com.library.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.*;

/**
 * 借阅业务逻辑层
 *
 * 核心设计：「申请即扣库存」策略 —— 读者提交借阅申请时立即扣减图书可借数量，
 * 而不是等到管理员批准时才扣。防止多个读者同时申请最后一本书的并发竞态问题。
 *
 * 状态流转：applying → borrowed → returned
 *                     ↘ rejected（还原库存）
 */
@Service
public class BorrowService {
    private final BorrowRepository borrowRepo;
    private final BookRepository bookRepo;
    private final UserRepository userRepo;

    public BorrowService(BorrowRepository borrowRepo, BookRepository bookRepo, UserRepository userRepo) {
        this.borrowRepo = borrowRepo;
        this.bookRepo = bookRepo;
        this.userRepo = userRepo;
    }

    /** 批量 JOIN 填充借阅记录的图书名称和读者姓名，用于列表展示 */
    public List<Map<String, Object>> enrich(List<Borrow> list) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Borrow b : list) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", b.getId());
            m.put("bookId", b.getBookId());
            m.put("userId", b.getUserId());
            m.put("status", b.getStatus());
            m.put("borrowDate", b.getBorrowDate().toString());
            m.put("dueDate", b.getDueDate().toString());
            m.put("returnDate", b.getReturnDate() != null ? b.getReturnDate().toString() : null);
            bookRepo.findById(b.getBookId()).ifPresent(book -> m.put("bookTitle", book.getTitle()));
            userRepo.findById(b.getUserId()).ifPresent(user -> m.put("userName", user.getName()));
            result.add(m);
        }
        return result;
    }

    /** 单条借阅记录 JOIN 填充 */
    public Map<String, Object> enrichOne(Borrow b) {
        return enrich(Collections.singletonList(b)).get(0);
    }

    /** 借阅记录列表查询，支持按用户ID、状态、图书ID筛选 */
    public Map<String, Object> list(Integer userId, String status, Integer bookId) {
        List<Borrow> list;
        if (userId != null && status != null) {
            list = borrowRepo.findByUserIdAndStatusOrderByIdDesc(userId, status);
        } else if (userId != null) {
            list = borrowRepo.findByUserIdOrderByIdDesc(userId);
        } else if (status != null) {
            list = borrowRepo.findByStatusOrderByIdDesc(status);
        } else {
            list = borrowRepo.findAllByOrderByIdDesc();
        }
        Map<String, Object> result = new HashMap<>();
        result.put("list", enrich(list));
        result.put("total", list.size());
        return result;
    }

    /**
     * 读者提交借阅申请
     *
     * 关键：申请时立即扣减库存（available - 1），而非等到管理员批准。
     * 这样即使多人同时申请，后续申请者也会因为 available <= 0 被拒绝，
     * 避免了"多人同时借到最后一本"的并发问题。
     *
     * @param bookId  图书ID
     * @param userId  用户ID
     * @param dueDate 应还日期，为空则默认30天
     */
    @Transactional
    public Map<String, Object> apply(Integer bookId, Integer userId, String dueDate) {
        // 1. 校验图书存在且有库存
        Book book = bookRepo.findById(bookId)
            .orElseThrow(() -> new RuntimeException("图书不存在"));
        if (book.getAvailable() <= 0)
            throw new RuntimeException("图书已全部借出");

        // 2. 校验用户存在且未被禁用
        User user = userRepo.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (user.getStatus() == 0)
            throw new RuntimeException("账号已被禁用");

        // 3. 立即扣库存，为申请者预留图书
        book.setAvailable(Math.max(0, book.getAvailable() - 1));
        bookRepo.save(book);

        // 4. 创建借阅记录，状态为「审核中」
        Borrow b = new Borrow();
        b.setBookId(bookId);
        b.setUserId(userId);
        b.setStatus("applying");
        b.setBorrowDate(LocalDate.now());
        b.setDueDate(dueDate != null ? LocalDate.parse(dueDate) : LocalDate.now().plusDays(30));
        b = borrowRepo.save(b);

        Map<String, Object> m = enrichOne(b);
        m.put("bookTitle", book.getTitle());
        m.put("userName", user.getName());
        return m;
    }

    /**
     * 管理员更新借阅状态（批准 / 拒绝 / 确认归还）
     *
     * 库存控制逻辑：
     * - 批准(borrowed)：库存已在申请时扣减，此处不重复扣
     * - 拒绝(rejected)：若原状态为applying，还原库存（+1）
     * - 归还(returned)：还原库存（+1），记录实际归还日期
     *
     * 所有操作在 @Transactional 事务中完成，保证数据一致性。
     */
    @Transactional
    public Map<String, Object> updateStatus(Integer id, String status) {
        Borrow b = borrowRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("借阅记录不存在"));
        Book book = bookRepo.findById(b.getBookId())
            .orElseThrow(() -> new RuntimeException("图书不存在"));

        // 拒绝申请 → 还原库存
        if ("rejected".equals(status) && "applying".equals(b.getStatus())) {
            book.setAvailable(Math.min(book.getTotal(), book.getAvailable() + 1));
            bookRepo.save(book);
        }
        // 归还（从borrowed或applying直接归还都需还原库存，因为申请时已扣过）
        if ("returned".equals(status) && ("borrowed".equals(b.getStatus()) || "applying".equals(b.getStatus()))) {
            book.setAvailable(Math.min(book.getTotal(), book.getAvailable() + 1));
            bookRepo.save(book);
            b.setReturnDate(LocalDate.now());
        }
        // 批准：库存已在申请时扣减，此处不重复操作

        b.setStatus(status);
        b = borrowRepo.save(b);
        return enrichOne(b);
    }
}

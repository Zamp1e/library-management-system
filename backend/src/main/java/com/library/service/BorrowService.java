package com.library.service;

import com.library.entity.Book;
import com.library.entity.Borrow;
import com.library.entity.User;
import com.library.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.*;

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

    public Map<String, Object> enrichOne(Borrow b) {
        return enrich(Collections.singletonList(b)).get(0);
    }

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

    @Transactional
    public Map<String, Object> apply(Integer bookId, Integer userId, String dueDate) {
        Book book = bookRepo.findById(bookId)
            .orElseThrow(() -> new RuntimeException("图书不存在"));
        if (book.getAvailable() <= 0)
            throw new RuntimeException("图书已全部借出");
        User user = userRepo.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (user.getStatus() == 0)
            throw new RuntimeException("账号已被禁用");

        // 申请时立即扣库存，防止多人同时借最后一本
        book.setAvailable(Math.max(0, book.getAvailable() - 1));
        bookRepo.save(book);

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

    @Transactional
    public Map<String, Object> updateStatus(Integer id, String status) {
        Borrow b = borrowRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("借阅记录不存在"));
        Book book = bookRepo.findById(b.getBookId())
            .orElseThrow(() -> new RuntimeException("图书不存在"));

        // 库存已在申请时扣减，批准时不重复扣
        // if ("borrowed".equals(status)) → no stock change

        if ("rejected".equals(status) && "applying".equals(b.getStatus())) {
            // 拒绝申请：还原库存
            book.setAvailable(Math.min(book.getTotal(), book.getAvailable() + 1));
            bookRepo.save(book);
        }
        if ("returned".equals(status) && ("borrowed".equals(b.getStatus()) || "applying".equals(b.getStatus()))) {
            // 归还（无论原状态是borrowed还是applying）：还原库存
            book.setAvailable(Math.min(book.getTotal(), book.getAvailable() + 1));
            bookRepo.save(book);
            b.setReturnDate(LocalDate.now());
        }
        b.setStatus(status);
        b = borrowRepo.save(b);
        return enrichOne(b);
    }
}

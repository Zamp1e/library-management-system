package com.library.service;

import com.library.entity.Book;
import com.library.repository.BookRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.*;

/**
 * 图书业务逻辑层
 *
 * 负责图书的增删改查及库存管理。
 * 更新图书时支持两种库存调整方式：
 * 1. 修改total时自动按差值调整available（防止直接操作库存）
 * 2. 显式传入available时直接设置（用于管理员矫正异常库存）
 */
@Service
public class BookService {
    private final BookRepository bookRepo;

    public BookService(BookRepository bookRepo) { this.bookRepo = bookRepo; }

    public Book get(Integer id) {
        return bookRepo.findById(id).orElseThrow(() -> new RuntimeException("图书不存在"));
    }

    public Map<String, Object> list(String keyword, String category) {
        String kw = (keyword != null && !keyword.isEmpty()) ? keyword : null;
        String cat = (category != null && !category.isEmpty()) ? category : null;
        List<Book> list = bookRepo.search(kw, cat);
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", list.size());
        return result;
    }

    public Book add(Book book) {
        book.setId(null);
        if (book.getTotal() == null) book.setTotal(1);
        if (book.getAvailable() == null) book.setAvailable(book.getTotal());
        if (book.getCreatedAt() == null) book.setCreatedAt(LocalDate.now());
        return bookRepo.save(book);
    }

    public Book update(Integer id, Book data) {
        Book book = get(id);
        if (data.getIsbn() != null) book.setIsbn(data.getIsbn());
        if (data.getTitle() != null) book.setTitle(data.getTitle());
        if (data.getAuthor() != null) book.setAuthor(data.getAuthor());
        if (data.getPublisher() != null) book.setPublisher(data.getPublisher());
        if (data.getCategory() != null) book.setCategory(data.getCategory());
        if (data.getPrice() != null) book.setPrice(data.getPrice());
        if (data.getTotal() != null) {
            int diff = data.getTotal() - book.getTotal();
            book.setTotal(data.getTotal());
            if (data.getAvailable() != null) {
                // 直接设置可借数量（如管理员手动矫正库存）
                book.setAvailable(Math.max(0, Math.min(data.getAvailable(), data.getTotal())));
            } else {
                book.setAvailable(Math.max(0, Math.min(book.getAvailable() + diff, data.getTotal())));
            }
        } else if (data.getAvailable() != null) {
            // 仅修改可借数量，不修改总数
            book.setAvailable(Math.max(0, Math.min(data.getAvailable(), book.getTotal())));
        }
        if (data.getLocation() != null) book.setLocation(data.getLocation());
        if (data.getCover() != null) book.setCover(data.getCover());
        if (data.getDescription() != null) book.setDescription(data.getDescription());
        return bookRepo.save(book);
    }

    public void delete(Integer id) {
        bookRepo.deleteById(id);
    }
}

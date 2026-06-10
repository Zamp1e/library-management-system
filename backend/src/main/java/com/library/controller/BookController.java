package com.library.controller;

import com.library.entity.Book;
import com.library.service.BookService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/books")
public class BookController {
    private final BookService bookService;

    public BookController(BookService bookService) { this.bookService = bookService; }

    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) String keyword,
                                     @RequestParam(required = false) String category) {
        return ApiResponse.ok(bookService.list(keyword, category));
    }

    @GetMapping("/{id}")
    public Map<String, Object> detail(@PathVariable Integer id) {
        return ApiResponse.ok(bookService.get(id));
    }

    @PostMapping
    public Map<String, Object> add(@RequestBody Book book) {
        return ApiResponse.ok(bookService.add(book));
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Integer id, @RequestBody Book book) {
        return ApiResponse.ok(bookService.update(id, book));
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Integer id) {
        bookService.delete(id);
        return ApiResponse.ok(null);
    }
}

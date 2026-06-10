package com.library.controller;

import com.library.service.BorrowService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/borrows")
public class BorrowController {
    private final BorrowService borrowService;

    public BorrowController(BorrowService borrowService) { this.borrowService = borrowService; }

    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) Integer userId,
                                     @RequestParam(required = false) String status,
                                     @RequestParam(required = false) Integer bookId) {
        return ApiResponse.ok(borrowService.list(userId, status, bookId));
    }

    @PostMapping
    public Map<String, Object> apply(@RequestBody Map<String, Object> body) {
        Integer bookId = (Integer) body.get("bookId");
        Integer userId = (Integer) body.get("userId");
        String dueDate = (String) body.get("dueDate");
        return ApiResponse.ok(borrowService.apply(bookId, userId, dueDate));
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Integer id, @RequestBody Map<String, Object> body) {
        String status = (String) body.get("status");
        return ApiResponse.ok(borrowService.updateStatus(id, status));
    }
}

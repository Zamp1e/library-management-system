package com.library.controller;

import com.library.repository.*;
import com.library.entity.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/** 统计控制器：仪表盘数据总览——图书数/读者数/借阅中/逾期/趋势/分类分布 */
@RestController
@RequestMapping("/api/stats")
public class StatsController {
    private final BookRepository bookRepo;
    private final UserRepository userRepo;
    private final BorrowRepository borrowRepo;

    public StatsController(BookRepository bookRepo, UserRepository userRepo, BorrowRepository borrowRepo) {
        this.bookRepo = bookRepo;
        this.userRepo = userRepo;
        this.borrowRepo = borrowRepo;
    }

    @GetMapping("/overview")
    public Map<String, Object> overview() {
        Map<String, Object> data = new HashMap<>();
        data.put("totalBooks", bookRepo.count());
        data.put("totalReaders", userRepo.findByRole("reader").size());
        data.put("borrowing", borrowRepo.countByStatus("borrowed"));
        data.put("overdue", borrowRepo.findOverdue().size());
        data.put("returnedToday", 0);

        // 借阅趋势（近6月）
        List<Map<String, Object>> trend = Arrays.asList(
            Map.of("month", "1月", "count", 12),
            Map.of("month", "2月", "count", 18),
            Map.of("month", "3月", "count", 25),
            Map.of("month", "4月", "count", 20),
            Map.of("month", "5月", "count", 32),
            Map.of("month", "6月", "count", 28));
        data.put("borrowingTrend", trend);

        // 分类分布
        List<Book> books = bookRepo.findAll();
        Map<String, Integer> catMap = new HashMap<>();
        for (Book b : books) {
            catMap.merge(b.getCategory(), 1, Integer::sum);
        }
        List<Map<String, Object>> catDist = new ArrayList<>();
        for (Map.Entry<String, Integer> e : catMap.entrySet()) {
            catDist.add(Map.of("name", e.getKey(), "value", e.getValue()));
        }
        data.put("categoryDist", catDist);

        return ApiResponse.ok(data);
    }
}

package com.library.controller;

import com.library.entity.User;
import com.library.service.UserService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** 用户控制器：增删改查，支持 role/keyword 筛选，限制不可提升为超管或删除超管 */
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) { this.userService = userService; }

    @GetMapping
    public Map<String, Object> list(@RequestParam(required = false) String role,
                                     @RequestParam(required = false) String keyword) {
        return ApiResponse.ok(userService.list(role, keyword));
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody User user) {
        User u = userService.create(user);
        return ApiResponse.ok(Map.of("id", u.getId()));
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Integer id, @RequestBody User user) {
        userService.update(id, user);
        return ApiResponse.ok(Map.of("id", id));
    }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Integer id) {
        userService.delete(id);
        return ApiResponse.ok(null);
    }
}

package com.library.controller;

import com.library.service.AuthService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) { this.authService = authService; }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        return ApiResponse.ok(authService.login(username, password));
    }

    @PostMapping("/register")
    public Map<String, Object> register() {
        throw new RuntimeException("注册已关闭，请联系管理员开通账号");
    }

    @GetMapping("/me")
    public Map<String, Object> me(@RequestHeader(value = "Authorization", defaultValue = "") String auth) {
        Integer userId = extractUserId(auth);
        return ApiResponse.ok(authService.me(userId));
    }

    public static Integer extractUserId(String auth) {
        if (auth == null || auth.isEmpty()) throw new RuntimeException("未登录");
        String token = auth.replace("Bearer ", "");
        String[] parts = token.split("-");
        return parts.length >= 2 ? Integer.parseInt(parts[1]) : null;
    }
}

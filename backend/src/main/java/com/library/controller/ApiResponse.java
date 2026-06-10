package com.library.controller;

import java.util.*;

public class ApiResponse {
    public static Map<String, Object> ok(Object data) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 200);
        map.put("data", data);
        return map;
    }

    public static Map<String, Object> error(int code, String message) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", code);
        map.put("message", message);
        return map;
    }
}

package com.library.config;

import com.library.controller.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** 全局异常处理器：捕获所有 RuntimeException，返回统一 JSON 格式错误 */
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, Object> handleRuntime(RuntimeException e) {
        return ApiResponse.error(400, e.getMessage());
    }
}

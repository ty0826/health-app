package com.health.controller;

import com.health.dto.ChatRequest;
import com.health.service.AiService;
import com.health.vo.Result;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    @Autowired
    private AiService aiService;

    @PostMapping("/chat")
    public Result<Map<String, String>> chat(HttpServletRequest request, @RequestBody ChatRequest chatRequest) {
        Long userId = (Long) request.getAttribute("userId");
        String reply = aiService.chat(userId, chatRequest.getMessage());

        Map<String, String> data = new HashMap<>();
        data.put("reply", reply);
        return Result.success(data);
    }
}

package com.health.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.health.entity.HealthData;
import com.health.mapper.HealthDataMapper;
import okhttp3.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.concurrent.TimeUnit;

@Service
public class AiService {

    private static final Logger log = LoggerFactory.getLogger(AiService.class);

    @Value("${ai.api-url}")
    private String apiUrl;

    @Value("${ai.api-key}")
    private String apiKey;

    @Value("${ai.model}")
    private String model;

    @Autowired
    private HealthDataMapper healthDataMapper;

    private final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

    public String chat(Long userId, String message) {
        try {
            // 获取用户最近健康数据作为上下文
            HealthData todayData = healthDataMapper.selectByUserAndDate(userId, LocalDate.now());
            String healthContext = buildHealthContext(todayData);

            // 构建请求
            JSONObject requestBody = new JSONObject();
            requestBody.put("model", model);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 1000);

            JSONArray messages = new JSONArray();

            // System prompt
            JSONObject systemMsg = new JSONObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", "你是一个专业的AI健康助手。你需要根据用户的健康数据，为用户提供个性化的健康建议。" +
                    "你的回答应该专业、友善、简洁，并且使用中文。" +
                    "以下是用户的健康数据：\n" + healthContext);
            messages.add(systemMsg);

            // User message
            JSONObject userMsg = new JSONObject();
            userMsg.put("role", "user");
            userMsg.put("content", message);
            messages.add(userMsg);

            requestBody.put("messages", messages);

            Request request = new Request.Builder()
                    .url(apiUrl)
                    .addHeader("Authorization", "Bearer " + apiKey)
                    .addHeader("Content-Type", "application/json")
                    .post(RequestBody.create(requestBody.toJSONString(),
                            MediaType.parse("application/json")))
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.isSuccessful() && response.body() != null) {
                    String responseBody = response.body().string();
                    JSONObject jsonResponse = JSON.parseObject(responseBody);
                    JSONArray choices = jsonResponse.getJSONArray("choices");
                    if (choices != null && !choices.isEmpty()) {
                        return choices.getJSONObject(0)
                                .getJSONObject("message")
                                .getString("content");
                    }
                }
            }
        } catch (IOException e) {
            log.error("AI API call failed", e);
        }

        // 如果AI API不可用，返回预设回复
        return generateFallbackReply(message);
    }

    private String buildHealthContext(HealthData data) {
        if (data == null) {
            return "暂无今日健康数据记录。";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("今日健康数据：\n");
        if (data.getSteps() != null && data.getSteps() > 0) sb.append("- 步数: ").append(data.getSteps()).append("步\n");
        if (data.getHeartRate() != null && data.getHeartRate() > 0) sb.append("- 心率: ").append(data.getHeartRate()).append("次/分\n");
        if (data.getSleepHours() != null) sb.append("- 睡眠: ").append(data.getSleepHours()).append("小时\n");
        if (data.getWeight() != null) sb.append("- 体重: ").append(data.getWeight()).append("kg\n");
        if (data.getSystolicBp() != null && data.getSystolicBp() > 0) sb.append("- 血压: ").append(data.getSystolicBp()).append("/").append(data.getDiastolicBp()).append("mmHg\n");
        if (data.getBloodSugar() != null) sb.append("- 血糖: ").append(data.getBloodSugar()).append("mmol/L\n");
        if (data.getCalories() != null && data.getCalories() > 0) sb.append("- 热量消耗: ").append(data.getCalories()).append("kcal\n");
        if (data.getWaterIntake() != null && data.getWaterIntake() > 0) sb.append("- 饮水: ").append(data.getWaterIntake()).append("ml\n");
        return sb.toString();
    }

    private String generateFallbackReply(String message) {
        if (message.contains("睡眠")) {
            return "改善睡眠质量的建议：\n\n" +
                    "1. 📱 睡前1小时避免使用电子设备\n" +
                    "2. 🌙 保持固定的作息时间\n" +
                    "3. 🧘 睡前可以做简单的拉伸或冥想\n" +
                    "4. ☕ 下午2点后避免咖啡因\n" +
                    "5. 🌡️ 保持卧室温度在18-22°C\n" +
                    "6. 🛏️ 选择舒适的寝具\n\n" +
                    "建议每天记录睡眠数据，以便追踪改善效果！";
        } else if (message.contains("运动") || message.contains("计划")) {
            return "今日运动建议：\n\n" +
                    "🏃 有氧运动\n- 快走30分钟 或 慢跑20分钟\n\n" +
                    "💪 力量训练（选做）\n- 俯卧撑 3组×15次\n- 深蹲 3组×20次\n- 平板支撑 3组×30秒\n\n" +
                    "🧘 拉伸放松\n- 运动后拉伸10分钟\n\n" +
                    "⚠️ 注意事项：\n" +
                    "- 运动前热身5分钟\n" +
                    "- 运动中注意补水\n" +
                    "- 根据自身情况调整强度";
        } else if (message.contains("饮食") || message.contains("吃")) {
            return "健康饮食建议：\n\n" +
                    "🥗 每日营养搭配：\n" +
                    "- 碳水化合物 50-60%\n" +
                    "- 蛋白质 15-20%\n" +
                    "- 脂肪 20-30%\n\n" +
                    "🥦 建议多吃：\n- 新鲜蔬果、全谷物、优质蛋白\n\n" +
                    "🚫 建议少吃：\n- 深加工食品、高糖饮料、过量盐分\n\n" +
                    "💧 每日饮水建议2000ml以上";
        } else {
            return "感谢你的提问！作为你的健康助手，我建议：\n\n" +
                    "1. 🏃 每天保持适量运动，目标步数 8000-10000 步\n" +
                    "2. 😴 保证充足睡眠 7-8 小时\n" +
                    "3. 💧 每天饮水 2000ml 以上\n" +
                    "4. 🥗 均衡膳食，多吃蔬果\n" +
                    "5. 🧘 保持良好心态，适当放松\n\n" +
                    "你可以问我更具体的问题，比如：\n" +
                    "- 如何改善睡眠质量？\n" +
                    "- 推荐今天的运动计划\n" +
                    "- 我需要注意哪些饮食？";
        }
    }
}

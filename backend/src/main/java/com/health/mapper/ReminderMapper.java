package com.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.health.entity.Reminder;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ReminderMapper extends BaseMapper<Reminder> {

    @Select("SELECT * FROM reminder WHERE user_id = #{userId} AND deleted = 0 ORDER BY id ASC")
    List<Reminder> selectByUserId(@Param("userId") Long userId);
}

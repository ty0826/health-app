package com.health.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.health.entity.Faq;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface FaqMapper extends BaseMapper<Faq> {

    @Select("SELECT * FROM faq WHERE enabled = 1 AND deleted = 0 ORDER BY sort_order ASC")
    List<Faq> selectEnabledList();
}

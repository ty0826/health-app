DELETE old_row
FROM health_data old_row
JOIN health_data newest
  ON newest.user_id = old_row.user_id
 AND newest.record_date = old_row.record_date
 AND newest.id > old_row.id;

SET @drop_index_sql = (
  SELECT IF(
    COUNT(*) > 0,
    'ALTER TABLE health_data DROP INDEX idx_user_date',
    'SELECT 1'
  )
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'health_data'
    AND index_name = 'idx_user_date'
);
PREPARE drop_index_statement FROM @drop_index_sql;
EXECUTE drop_index_statement;
DEALLOCATE PREPARE drop_index_statement;

SET @add_unique_sql = (
  SELECT IF(
    COUNT(*) = 0,
    'ALTER TABLE health_data ADD UNIQUE KEY uk_user_date (user_id, record_date)',
    'SELECT 1'
  )
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'health_data'
    AND index_name = 'uk_user_date'
    AND non_unique = 0
);
PREPARE add_unique_statement FROM @add_unique_sql;
EXECUTE add_unique_statement;
DEALLOCATE PREPARE add_unique_statement;

-- 创建用户LLM偏好表
CREATE TABLE IF NOT EXISTS user_llm_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    provider VARCHAR(50) NOT NULL DEFAULT 'deepseek',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    UNIQUE(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_llm_preferences_user_id ON user_llm_preferences(user_id);

-- 插入默认数据（为已有用户）
INSERT OR IGNORE INTO user_llm_preferences (user_id, provider, created_at, updated_at)
SELECT id, 'deepseek', strftime('%s', 'now'), strftime('%s', 'now')
FROM users;


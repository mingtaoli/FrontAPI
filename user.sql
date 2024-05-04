-- Drop the table if it already exists
DROP TABLE IF EXISTS users;

-- Create new table
CREATE TABLE users (
    UserID SERIAL PRIMARY KEY,
    LoginName VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    Phone VARCHAR(255),
    EnableFlag SMALLINT DEFAULT 1 NOT NULL,
    NickName VARCHAR(255),
    AvatarUrl VARCHAR(255),
    CreatedTime TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Deleted SMALLINT DEFAULT 0
);


INSERT INTO users (LoginName, Password, Email, Phone, EnableFlag, NickName, AvatarUrl, CreatedTime, Deleted)
VALUES ('mingtaoli', '123456Ab', 'mingtao@xjtu.edu.cn', '17782560245', 1, 'Victor', NULL, CURRENT_TIMESTAMP, 0);

/*
DANH SÁCH CÁC BẢNG:
1. Question - Lưu câu hỏi với đáp án JSON
2. Game - Lưu thông tin game
3. DailyQuizResult - Lưu kết quả người chơi
4. GameType - Lưu loại game
5. GameSettings - Lưu cài đặt game
6. GameSchedule - Lưu lịch trình game
7. GameReward - Lưu phần thưởng game
8. LeaderBoard - Lưu bảng xếp hạng
9. LeaderBoardEntry - Lưu dữ liệu bảng xếp hạng
10. GameSession - Lưu phiên chơi game (với mã PIN)
11. GameSessionPlayer - Lưu người chơi trong phiên
12. GameSessionAnswer - Lưu câu trả lời trong phiên
*/

-- Bảng Question với danh sách answers dạng JSON
CREATE TABLE Question (
    QuestionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Content NVARCHAR(2000) NOT NULL,
    Answers NVARCHAR(2000) NOT NULL, -- JSON format: [{"id":"1", "content":"Đáp án A", "isCorrect":true},...]
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng Game
CREATE TABLE Game (
    GameID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Title NVARCHAR(255) NOT NULL,
    Questions NVARCHAR(2000) NOT NULL, -- JSON format: ["1", "2", "3",...] (list of QuestionIDs)
    GameType NVARCHAR(50) DEFAULT 'daily-quiz',
    Status NVARCHAR(20) DEFAULT 'active',
    PinCode NVARCHAR(10),
    GameTypeID UNIQUEIDENTIFIER,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng DailyQuizResult
CREATE TABLE DailyQuizResult (
    ResultID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    GameID UNIQUEIDENTIFIER NOT NULL,
    Score INT NOT NULL,
    TimeSpent INT NOT NULL, -- Thời gian tính bằng giây
    IsWon BIT DEFAULT 0, -- 0: False, 1: True
    CompletedAt DATETIME NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng GameType để mở rộng nhiều loại game
CREATE TABLE GameType (
    GameTypeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(2000),
    Rules NVARCHAR(2000),
    RewardSystem NVARCHAR(2000),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng GameSettings cho các cài đặt của game
CREATE TABLE GameSettings (
    SettingsID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GameID UNIQUEIDENTIFIER NOT NULL,
    TimeLimit INT, -- Thời gian giới hạn (giây)
    MaxAttempts INT DEFAULT 1,
    PointsPerQuestion INT DEFAULT 10,
    NegativeMarking BIT DEFAULT 0,
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

-- Bảng GameSchedule để lịch trình game
CREATE TABLE GameSchedule (
    ScheduleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GameID UNIQUEIDENTIFIER NOT NULL,
    StartAt DATETIME,
    EndAt DATETIME,
    IsRecurring BIT DEFAULT 0,
    RecurrencePattern NVARCHAR(50), -- daily, weekly, monthly
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

-- Bảng GameReward cho phần thưởng
CREATE TABLE GameReward (
    RewardID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GameID UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(2000),
    Value DECIMAL(18, 2),
    Type NVARCHAR(50), -- cash, voucher, item
    WinCondition NVARCHAR(50), -- top-score, random-selection, all-participants
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

-- Bảng LeaderBoard
CREATE TABLE LeaderBoard (
    LeaderBoardID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GameID UNIQUEIDENTIFIER NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Type NVARCHAR(50) DEFAULT 'global', -- global, daily, weekly, monthly
    StartDate DATETIME,
    EndDate DATETIME,
    MaxEntries INT DEFAULT 100,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

-- Bảng LeaderBoardEntry
CREATE TABLE LeaderBoardEntry (
    EntryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    LeaderBoardID UNIQUEIDENTIFIER NOT NULL,
    UserID UNIQUEIDENTIFIER NOT NULL,
    Score INT NOT NULL,
    TimeSpent INT NOT NULL,
    Rank INT,
    EntryDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (LeaderBoardID) REFERENCES LeaderBoard(LeaderBoardID)
);

-- Bảng GameSession
CREATE TABLE GameSession (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GameID UNIQUEIDENTIFIER NOT NULL,
    PinCode NVARCHAR(10) NOT NULL,
    HostUserID UNIQUEIDENTIFIER NOT NULL,
    Status NVARCHAR(20) DEFAULT 'waiting', -- waiting, active, completed, cancelled
    CurrentQuestionIndex INT DEFAULT 0,
    StartedAt DATETIME,
    EndedAt DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

-- Bảng GameSessionPlayer
CREATE TABLE GameSessionPlayer (
    SessionPlayerID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SessionID UNIQUEIDENTIFIER NOT NULL,
    UserID UNIQUEIDENTIFIER NOT NULL,
    Nickname NVARCHAR(100),
    CurrentScore INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    JoinedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SessionID) REFERENCES GameSession(SessionID),
    CONSTRAINT UQ_GameSessionPlayer UNIQUE (SessionID, UserID)
);

-- Bảng GameSessionAnswer
CREATE TABLE GameSessionAnswer (
    SessionAnswerID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SessionID UNIQUEIDENTIFIER NOT NULL,
    QuestionID UNIQUEIDENTIFIER NOT NULL,
    UserID UNIQUEIDENTIFIER NOT NULL,
    AnswerSelected NVARCHAR(50) NOT NULL, -- ID của đáp án được chọn
    IsCorrect BIT,
    ResponseTime INT, -- Thời gian phản hồi tính bằng mili giây
    PointsEarned INT DEFAULT 0,
    AnsweredAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SessionID) REFERENCES GameSession(SessionID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    CONSTRAINT UQ_GameSessionAnswer UNIQUE (SessionID, QuestionID, UserID)
);

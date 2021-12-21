/*
*   author:Master
*	Date : 2021/12
*   Function : Trie Tree Search By Iteration
*/

USE Trie_Tree
GO

Create FUNCTION Search(@In_Str nvarchar(max))
RETURNS INT
AS
BEGIN
    -- 定义游标中取出的数据
    DECLARE @Get_Id int,@Element char(1), @Next_Ptr int, @Next_Chain int, @Count int
    -- 定义游标并且初始化
    DECLARE PTR CURSOR SCROLL FOR SELECT * FROM Trie_Tree 
    -- 定义循环判断变量
    DECLARE @CHECK_WHILE bit
    SET @CHECK_WHILE = 1
    -- 打开
    OPEN PTR
    -- 迭代正在处理的元素位置
    DECLARE @Position INT,@Now_Element Char(1)
    SET @Position = 1
    -- 当且迭代对象的游标
    DECLARE @Now_Cursor INT
    SET @Now_Cursor = 1
	-- 定义输出的值
	DECLARE @Get_Count INT
    -- 迭代
    WHILE @CHECK_WHILE = 1
        BEGIN
            -- 获取当前正在处理的字符
            SET @Now_Element = SUBSTRING(@In_Str,@Position,@Position)
            -- 获取游标元素
            FETCH ABSOLUTE @Now_Cursor FROM Ptr into @Get_Id,@Element,@Next_Ptr,@Next_Chain,@Count
            -- 判定现在这个字符
            IF @Element = @Now_Element
                -- 处理字符与迭代帧相同
				BEGIN
                    IF @Position = LEN(@In_Str)
						-- 最后一位处理完毕
                        begin
						    SET @Get_Count = @Count
                            SET @CHECK_WHILE= 0
                        end
					ELSE
                        -- 进入下一个叶子节点，处理下一个字符
                        BEGIN
                            IF @Next_Ptr < 0
                                BEGIN
                                    
                                    SET @Get_Count = -1
                                    SET @CHECK_WHILE= 0
                                END
                            ELSE
                                BEGIN
                                    SET @Position = @Position + 1
                                    SET @Now_Cursor = @Next_Ptr
                                END
                        END	
                END
			ELSE
				BEGIN
					IF @Next_Chain < 0
                        begin
						-- 没有链节点
						    SET @Get_Count = -1
                            SET @CHECK_WHILE= 0
                        end
					ELSE
						-- 有链节点继续迭代
						SET @Now_Cursor = @Next_Chain
				END
        END
	RETURN @Get_Count
END
go

-- Use Example
declare @sttr nvarchar(max),@AD INT
set @sttr = 'AB32F'
EXEC @AD = ASearch @sttr
select @AD
/*
*   author:Master
*	Date : 2021/12
*   Function : Trie Tree Insert(Recursion)
*   Warning : The Sql Server Maximize Recursion Layers Is 32 
*/


USE Trie_Tree
GO


Create PROC Tree_Insert 
/*
*   @Ptr_Line       int                 代表当前函数帧处理的游标位置 
*   @in_str         varchar(max)        代表输入的字符串
*   @position       int                 代表当前字符串正在处理哪个位置
*/
@Ptr_Line int,@in_str varchar(max),@position int
AS
BEGIN
    DECLARE @RETUNR_BACK INT                											-- 定义变量保存递归返回值
    DECLARE @Get_Id int,@Element char(1), @Next_Ptr int, @Next_Chain int, @Count int    -- 游标取出的元素
    DECLARE Ptr CURSOR LOCAL SCROLL OPTIMISTIC                                          -- 定义游标
        FOR SELECT * FROM Trie_Tree 
        FOR UPDATE OF Next_Chain,Next_Ptr,[Count]
    DECLARE @Get_Element char(1)                                                        -- 获取这个函数帧处理的字符串的字符
    SET @Get_Element = SUBSTRING(@in_str,@position,@position)
    OPEN  Ptr                                                                           -- 打开游标
    FETCH ABSOLUTE @Ptr_Line FROM Ptr into @Get_Id,@Element,@Next_Ptr,@Next_Chain,@Count-- 从游标中获取数据
    IF @position > LEN (@in_str)                                                 -- 判定递归终点
        BEGIN
            RETURN
        END
    IF CAST(@Get_Element as varbinary) = CAST(@Element as varbinary)                    -- 判定是否符合当前节点的元素,区分大小写
        BEGIN                                                                           -- 符合
            IF @position < LEN (@in_str)                                         		-- 如果还有字符没有处理
                BEGIN  
                    SET @position = @position + 1                                       -- 处理位置后推一个,用于递归传值
                    IF @Next_Ptr > 0                                                    -- 如果有下一个叶子节点，直接递归
                        BEGIN
                            EXEC Tree_Insert @Next_Ptr,@in_str,@position
                            CLOSE  Ptr
                            deallocate   Ptr
                        END
                    ELSE                                                                -- 如果没有下一个叶子节点,那么创建一个并且递归
                        BEGIN
                            SET @Get_Element = SUBSTRING(@in_str,@position,@position)
                            INSERT INTO Trie_Tree VALUES (@Get_Element,-1,-1,0)         -- 创建一个节点
                            UPDATE Trie_Tree SET Next_Ptr = SCOPE_IDENTITY()  where Current of Ptr      -- 更新本节点
                            EXEC Tree_Insert @Next_Ptr,@in_str,@position                           		-- 递归
                            CLOSE  Ptr
                            deallocate   Ptr
                        END
                END 
            ELSE
                BEGIN                                                                           		-- 这个帧就是最后一个帧，处理字符串最后一个元素
                    UPDATE Trie_Tree SET [Count] = [Count] + 1 where current of Ptr
                    RETURN
                END
        END
    ELSE                                                                                       			--这个节点不符合当前元素，那么寻找节点链表的下一个元素
        BEGIN
            IF @Next_Chain > 0
                BEGIN
                    EXEC Tree_Insert @Next_Chain,@in_str,@position                 						-- 这个节点还有下一个链节点——那么横向递归
                    CLOSE  Ptr
                    deallocate   Ptr
                END
            ELSE
                BEGIN
                    INSERT INTO Trie_Tree VALUES (@Get_Element,-1,-1,0)                         		-- 这个节点没有下一个链——横向创建再递归
                    UPDATE Trie_Tree SET Next_Chain =  SCOPE_IDENTITY() where current of Ptr           	-- 更新本节点
                    EXEC Tree_Insert @Next_Chain,@in_str,@position                  					-- 递归

                    CLOSE  Ptr
                    deallocate   Ptr
                END
            RETURN
        END
END
GO



-- Use Example
DECLARE @Ptr_Line int,@in_str varchar(max),@position int
SET @position = 1
SET @in_str = 'AB3F'
SET @Ptr_Line = 1
EXEC Tree_Insert @Ptr_Line,@in_str,@position
go

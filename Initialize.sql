/*
*   author:Master
*	Date : 2021/12
*   Function : initialize database(This stored procedure include delecting table and creating root item)
*/
USE Trie_Tree
GO

CREATE PROC Initialize_Table
AS
BEGIN
    TRUNCATE TABLE Trie_Tree
    INSERT INTO Trie_Tree(Element,Next_Ptr,Next_Chain,[Count]) VALUES (Null,-1,-1,0)  
END
GO


EXEC Initialize_Table
GO
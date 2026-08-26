
-- Find orphan order records without valid customer IDs
SELECT * FROM Orders
WHERE CustomerID NOT IN (SELECT CustomerID FROM Customers);

SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO Orders (CustomerID, Status, TotalAmount) VALUES (9999, 'Pending', 100.00);
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM Orders WHERE CustomerID NOT IN (SELECT CustomerID FROM Customers);
-- Should now return the bad row you just inserted

DELETE FROM Orders WHERE CustomerID = 9999;  -- clean up afterward
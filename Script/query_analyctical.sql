-- DWH query to displays historical training data
SELECT
  e.EmployeeId,
  e.FullName,
  th.TrainingName,
  th.TRAININGDATE_START AS DATE_START,
  th.TRAININGDATE_END AS DATE_END,
  th.TrainingDuration AS Training_Duration_DAY,
  th.TrainingLocation,
  CASE
    WHEN th.TRAININGDATE_END < CURRENT_DATE THEN 'Completed'
    ELSE 'On Going'
  END AS Status
FROM
  DataWarehouse.Employee e
  JOIN DataWarehouse.TrainingHistory th ON e.EmployeeId = th.EmployeeId;

-- a. Total employee completed training each month
WITH cte AS (
  SELECT
    e.EmployeeId,
    YEAR(th.TRAININGDATE_START) AS Year,
    MONTH(th.TRAININGDATE_START) AS Month,
    COUNT(*) AS TotalTraining,
    SUM(CASE WHEN th.TRAININGDATE_END < GETDATE() THEN 1 ELSE 0 END) AS CompletedTraining
  FROM
    DataWarehouse.Employee e
    JOIN DataWarehouse.TrainingHistory th ON e.EmployeeId = th.EmployeeId
  GROUP BY
    e.EmployeeId, YEAR(th.TRAININGDATE_START), MONTH(th.TRAININGDATE_START)
)

SELECT
  cte.Year,
  cte.Month,
  COUNT(DISTINCT cte.EmployeeId) AS TotalDistinctEmployee,
  SUM(CASE WHEN cte.CompletedTraining = cte.TotalTraining THEN 1 ELSE 0 END) AS TotalCompletedEmployee,
  SUM(CASE WHEN cte.CompletedTraining < cte.TotalTraining THEN 1 ELSE 0 END) AS TotalOngoingEmployee
FROM
  cte
GROUP BY
  cte.Year, cte.Month
ORDER BY
  cte.Year, cte.Month;
 
-- b. Total training each month
-- DataWarehouse.total_training source

WITH cte AS (
  SELECT
    e.EmployeeId,
    e.FullName,
    th.TrainingName,
    th.TRAININGDATE_START AS DATE_START,
    th.TRAININGDATE_END AS DATE_END,
    th.TrainingDuration AS Training_Duration_DAY,
    th.TrainingLocation,
    CASE
      WHEN th.TRAININGDATE_END < CURRENT_DATE THEN 'Completed'
      ELSE 'On Going'
    END AS Status
  FROM
    DataWarehouse.Employee e
    JOIN DataWarehouse.TrainingHistory th ON e.EmployeeId = th.EmployeeId
)
SELECT
  YEAR(DATE_START) AS Year,
  MONTH(DATE_START) AS Month,
  COUNT(*) AS TotalTraining,
  SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS TotalCompletedTraining,
  SUM(CASE WHEN Status = 'On Going' THEN 1 ELSE 0 END) AS TotalOngoingTraining
FROM
  cte
GROUP BY
  YEAR(DATE_START),
  MONTH(DATE_START)
;


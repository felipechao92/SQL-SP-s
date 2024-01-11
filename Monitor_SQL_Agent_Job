 /*
=======================================================================================
Overview
This script is designed to monitor the status of a specific SQL Server Agent job. 
It checks if the job is currently running and, if so, calculates its runtime. If it detects that the job is stuck or running longer than expected, it triggers an email notification to a predefined list of recipients.

Features
Monitors a specific SQL Server Agent job.
Calculates the runtime of the job if it's currently executing.
Sends an email alert if the job is perceived to be stuck.

Implementation Details
Variables Declaration: Initializes variables to store job status, name, start time, and runtime.
Job Status Check: Queries msdb..sysjobactivity and msdb..sysjobs to fetch the current status of the sql agent job.
Runtime Calculation: If the job is running, calculates the current runtime.
Email Trigger: If the job is found to be running for an unusually long time (stuck), composes an alert message and sends an email to a list of recipients.

Variables
@status: Job stop execution date/time.
@job: Job name.
@start: Job start execution date/time.
@runtime: Total runtime of the job.
@msg: Message to be sent in the email.

Email Notification
Uses msdb.dbo.sp_send_dbmail to send email.
Recipients, subject, and body are defined within the script.
The body includes the job name, runtime, and start time.

Usage
Run this script on the SQL Server instance where the job is scheduled. It's ideal for scheduling as a frequent check, especially in environments where this job is critical and its timely execution is essential.

Author         : Felipe Chao 16 Feb 2023
========================================================================================= 
*/


DECLARE @start NVARCHAR (50)
DECLARE @msg NVARCHAR (250)
DECLARE @status NVARCHAR (50)
DECLARE @job NVARCHAR (50)
DECLARE @runtime NVARCHAR (50)

SELECT
	@status = aj.stop_execution_date
   ,@job = sj.name
   ,@start = aj.start_execution_date
   ,@runtime = CONVERT(CHAR(8), DATEADD(SS, DATEDIFF(SECOND, aj.start_execution_date, GETDATE()), 0), 108)
FROM msdb..sysjobactivity aj
JOIN msdb..sysjobs sj
	ON sj.job_id = aj.job_id
WHERE aj.stop_execution_date IS NULL
AND aj.start_execution_date IS NOT NULL
AND sj.name = '' -- Your SQL Agent Job
AND session_id = (SELECT
		MAX(session_id)
	FROM msdb.dbo.sysjobactivity)

IF @status IS NULL
	AND @start IS NOT NULL
BEGIN
	SET @msg = 'The job ' + @job + ' Is stuck and it has been runining for: ' + @runtime + ' It started at: ' + @start

EXEC msdb.dbo.sp_send_dbmail
   @recipients = '@hotmail.com; @hotmail.com; @hotmail.com;  @hotmail.com; @hotmail.com',  --add users
    @subject = 'SQL Agent Job is stuck',
    @Body = @msg;

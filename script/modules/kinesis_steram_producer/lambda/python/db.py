# --------------------------------------------------------------------------------
# Job database interface definitions
# --------------------------------------------------------------------------------
import job_record

def create(record):
	"""Create a job record in the job table

	Args:
		record: a job record that the job table expects

	Returns: job id for the new job table record
	"""
	return job_record.create(record)

def start(record):
	"""Update the job record with the job start.

	Args:
		record: a job record that the job table expects

	Returns: job id for the new job table record
	"""
	return job_record.start(record)

def end(record):
	"""Update the job record with the job end.

	Args:
		record: a job record that the job table expects

	Returns: job id for the new job table record
	"""
	return job_record.end(record)

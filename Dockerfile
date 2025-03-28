# Use the official Python image as the base
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /working_dir

# Copy application files to the container
COPY app .

# Install required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port Flask runs on
EXPOSE 8080

# Run the Flask app
CMD ["python", "application.py"]

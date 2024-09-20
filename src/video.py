import cv2
import os
import re

# Directory containing the images
image_folder = './sim'

# Output video file
video_name = 'output_video.mp4'

# Get the list of images
images = [img for img in os.listdir(image_folder) if img.endswith(".png") or img.endswith(".jpg")]

def numerical_sort(value):
    numbers = re.findall(r'\d+', value)
    return int(numbers[0]) if numbers else 0
images.sort(key=numerical_sort)


# Read the first image to get the dimensions
frame = cv2.imread(os.path.join(image_folder, images[0]))
height, width, layers = frame.shape

# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # You can use 'XVID' for .avi files
video = cv2.VideoWriter(video_name, fourcc, 10.0, (width, height))

# Add each image to the video
for image in images:
    frame = cv2.imread(os.path.join(image_folder, image))
    video.write(frame)

# Release the video writer
video.release()

print(f"Video saved as {video_name}")
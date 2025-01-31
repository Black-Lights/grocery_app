import os

def list_png_files(folder_path, output_file):
    try:
        # Get all .png files from the specified folder
        png_files = [f for f in os.listdir(folder_path) if f.lower().endswith('.png')]
        
        # Write the list to a text file
        with open(output_file, 'w') as file:
            for png in png_files:
                file.write(png + '\n')
        
        print(f"Successfully written {len(png_files)} PNG filenames to {output_file}")
    except Exception as e:
        print(f"Error: {e}")

# Example usage
folder_path = r"C:\dev\linux\docker\grocery\assets\images\category_icons"

output_file = "png_files_list.txt"    # Output text file

list_png_files(folder_path, output_file)
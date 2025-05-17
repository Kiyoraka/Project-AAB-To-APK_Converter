@echo off
echo Creating AAB to APK Converter EXE...

rem Check if Python is installed
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed! Please install Python first.
    pause
    exit /b
)

rem Create a temporary directory
if not exist "temp" mkdir temp
cd temp

rem Create the Python file
echo Creating Python file...
(
echo import os
echo import subprocess
echo import sys
echo import tkinter as tk
echo from tkinter import filedialog, messagebox, ttk
echo from threading import Thread
echo.
echo.
echo class AABtoAPKConverter:
echo     def __init__(self, root^):
echo         self.root = root
echo         self.root.title("AAB to APK Converter"^)
echo         self.root.geometry("700x500"^)
echo         self.root.resizable(True, True^)
echo         
echo         # Set minimum window size
echo         self.root.minsize(600, 400^)
echo         
echo         # Variables
echo         self.aab_files = []
echo         self.output_dir = ""
echo         self.bundletool_path = ""
echo         self.keystore_path = ""
echo         self.keystore_pass = tk.StringVar(value="android"^)
echo         
echo         # Create GUI elements
echo         self.create_widgets(^)
echo         
echo         # Check for Java installation
echo         self.check_java(^)
echo.
echo     def create_widgets(self^):
echo         # Create main frame with padding
echo         main_frame = ttk.Frame(self.root, padding="10"^)
echo         main_frame.pack(fill=tk.BOTH, expand=True^)
echo         
echo         # Title
echo         title_label = ttk.Label(main_frame, text="AAB to APK Converter", font=("Helvetica", 16, "bold"^)^)
echo         title_label.pack(pady=10^)
echo         
echo         # Input section
echo         input_frame = ttk.LabelFrame(main_frame, text="Input Files", padding="10"^)
echo         input_frame.pack(fill=tk.X, pady=5^)
echo         
echo         # AAB files selection
echo         aab_frame = ttk.Frame(input_frame^)
echo         aab_frame.pack(fill=tk.X, pady=5^)
echo         
echo         self.aab_label = ttk.Label(aab_frame, text="No AAB files selected"^)
echo         self.aab_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5^)^)
echo         
echo         aab_btn = ttk.Button(aab_frame, text="Select AAB Files", command=self.select_aab_files^)
echo         aab_btn.pack(side=tk.RIGHT^)
echo         
echo         # Output directory selection
echo         output_frame = ttk.Frame(input_frame^)
echo         output_frame.pack(fill=tk.X, pady=5^)
echo         
echo         self.output_label = ttk.Label(output_frame, text="No output directory selected"^)
echo         self.output_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5^)^)
echo         
echo         output_btn = ttk.Button(output_frame, text="Select Output Directory", command=self.select_output_dir^)
echo         output_btn.pack(side=tk.RIGHT^)
echo         
echo         # Tools section
echo         tools_frame = ttk.LabelFrame(main_frame, text="Tools Configuration", padding="10"^)
echo         tools_frame.pack(fill=tk.X, pady=5^)
echo         
echo         # Bundletool selection
echo         bundletool_frame = ttk.Frame(tools_frame^)
echo         bundletool_frame.pack(fill=tk.X, pady=5^)
echo         
echo         self.bundletool_label = ttk.Label(bundletool_frame, text="No bundletool.jar selected"^)
echo         self.bundletool_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5^)^)
echo         
echo         bundletool_btn = ttk.Button(bundletool_frame, text="Select bundletool.jar", command=self.select_bundletool^)
echo         bundletool_btn.pack(side=tk.RIGHT^)
echo         
echo         # Keystore selection
echo         keystore_frame = ttk.Frame(tools_frame^)
echo         keystore_frame.pack(fill=tk.X, pady=5^)
echo         
echo         self.keystore_label = ttk.Label(keystore_frame, text="No keystore selected (optional^)"^)
echo         self.keystore_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5^)^)
echo         
echo         keystore_btn = ttk.Button(keystore_frame, text="Select Keystore", command=self.select_keystore^)
echo         keystore_btn.pack(side=tk.RIGHT^)
echo         
echo         # Keystore password
echo         pass_frame = ttk.Frame(tools_frame^)
echo         pass_frame.pack(fill=tk.X, pady=5^)
echo         
echo         ttk.Label(pass_frame, text="Keystore Password:"^).pack(side=tk.LEFT^)
echo         pass_entry = ttk.Entry(pass_frame, textvariable=self.keystore_pass, show="*"^)
echo         pass_entry.pack(side=tk.LEFT, padx=5^)
echo         
echo         # Convert button
echo         convert_btn = ttk.Button(main_frame, text="Convert AAB to APK", command=self.start_conversion, style="Accent.TButton"^)
echo         convert_btn.pack(pady=10^)
echo         
echo         # Create custom style for the convert button
echo         style = ttk.Style(^)
echo         style.configure("Accent.TButton", font=("Helvetica", 12, "bold"^)^)
echo         
echo         # Progress bar
echo         self.progress_bar = ttk.Progressbar(main_frame, mode="determinate"^)
echo         self.progress_bar.pack(fill=tk.X, pady=5^)
echo         
echo         # Log area
echo         log_frame = ttk.LabelFrame(main_frame, text="Conversion Log", padding="10"^)
echo         log_frame.pack(fill=tk.BOTH, expand=True, pady=5^)
echo         
echo         # Scrollbar for log
echo         scrollbar = ttk.Scrollbar(log_frame^)
echo         scrollbar.pack(side=tk.RIGHT, fill=tk.Y^)
echo         
echo         # Log text widget
echo         self.log_text = tk.Text(log_frame, height=10, wrap=tk.WORD, yscrollcommand=scrollbar.set^)
echo         self.log_text.pack(fill=tk.BOTH, expand=True^)
echo         scrollbar.config(command=self.log_text.yview^)
echo         
echo         # Status bar
echo         self.status_var = tk.StringVar(value="Ready"^)
echo         status_bar = ttk.Label(main_frame, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W^)
echo         status_bar.pack(fill=tk.X, pady=(5, 0^)^)
echo.
echo     def check_java(self^):
echo         try:
echo             subprocess.run(["java", "-version"], check=True, capture_output=True^)
echo             self.log("Java detected on system."^)
echo         except (subprocess.SubprocessError, FileNotFoundError^):
echo             messagebox.showerror("Java Not Found", "Java is required but not found on your system. Please install Java to use this application."^)
echo             self.log("ERROR: Java not found. Please install Java to continue."^)
echo.
echo     def select_aab_files(self^):
echo         files = filedialog.askopenfilenames(
echo             title="Select AAB Files",
echo             filetypes=[("Android App Bundle", "*.aab"^), ("All Files", "*.*"^)]
echo         ^)
echo         if files:
echo             self.aab_files = files
echo             if len(files^) == 1:
echo                 self.aab_label.config(text=os.path.basename(files[0]^)^)
echo             else:
echo                 self.aab_label.config(text=f"{len(files^)} AAB files selected"^)
echo             self.log(f"Selected {len(files^)} AAB file(s^)"^)
echo.
echo     def select_output_dir(self^):
echo         directory = filedialog.askdirectory(title="Select Output Directory"^)
echo         if directory:
echo             self.output_dir = directory
echo             self.output_label.config(text=directory^)
echo             self.log(f"Output directory set to: {directory}"^)
echo.
echo     def select_bundletool(self^):
echo         file = filedialog.askopenfilename(
echo             title="Select bundletool.jar",
echo             filetypes=[("JAR files", "*.jar"^), ("All Files", "*.*"^)]
echo         ^)
echo         if file:
echo             self.bundletool_path = file
echo             self.bundletool_label.config(text=os.path.basename(file^)^)
echo             self.log(f"Bundletool set to: {file}"^)
echo.
echo     def select_keystore(self^):
echo         file = filedialog.askopenfilename(
echo             title="Select Keystore",
echo             filetypes=[("Keystore files", "*.keystore;*.jks"^), ("All Files", "*.*"^)]
echo         ^)
echo         if file:
echo             self.keystore_path = file
echo             self.keystore_label.config(text=os.path.basename(file^)^)
echo             self.log(f"Keystore set to: {file}"^)
echo.
echo     def log(self, message^):
echo         self.log_text.insert(tk.END, message + "\n"^)
echo         self.log_text.see(tk.END^)
echo         print(message^)  # Also print to console for debugging
echo.
echo     def update_status(self, message^):
echo         self.status_var.set(message^)
echo         self.root.update_idletasks(^)
echo.
echo     def validate_inputs(self^):
echo         if not self.aab_files:
echo             messagebox.showwarning("No Input", "Please select at least one AAB file."^)
echo             return False
echo         
echo         if not self.output_dir:
echo             messagebox.showwarning("No Output", "Please select an output directory."^)
echo             return False
echo         
echo         if not self.bundletool_path:
echo             messagebox.showwarning("No Bundletool", "Please select bundletool.jar file."^)
echo             return False
echo         
echo         # If no keystore is selected, warn the user but allow them to proceed
echo         if not self.keystore_path:
echo             result = messagebox.askokcancel(
echo                 "No Keystore", 
echo                 "No keystore selected. The conversion may fail without a keystore. Continue anyway?"
echo             ^)
echo             if not result:
echo                 return False
echo         
echo         return True
echo.
echo     def start_conversion(self^):
echo         if not self.validate_inputs(^):
echo             return
echo         
echo         # Disable UI elements during conversion
echo         self.root.config(cursor="wait"^)
echo         for widget in self.root.winfo_children(^):
echo             if isinstance(widget, ttk.Button^):
echo                 widget.config(state=tk.DISABLED^)
echo         
echo         # Reset progress bar
echo         self.progress_bar["value"] = 0
echo         total_files = len(self.aab_files^)
echo         progress_step = 100 / total_files if total_files ^> 0 else 0
echo         
echo         # Start conversion in a separate thread to keep UI responsive
echo         conversion_thread = Thread(target=self.perform_conversion, args=(progress_step,^)^)
echo         conversion_thread.daemon = True
echo         conversion_thread.start(^)
echo.
echo     def perform_conversion(self, progress_step^):
echo         try:
echo             self.log("Starting conversion process..."^)
echo             self.update_status("Converting..."^)
echo             
echo             success_count = 0
echo             for i, aab_file in enumerate(self.aab_files^):
echo                 file_name = os.path.basename(aab_file^)
echo                 base_name = os.path.splitext(file_name^)[0]
echo                 self.log(f"Processing file {i+1}/{len(self.aab_files^)}: {file_name}"^)
echo                 
echo                 # Create command for bundletool
echo                 apks_output = os.path.join(self.output_dir, f"{base_name}.apks"^)
echo                 apk_output = os.path.join(self.output_dir, f"{base_name}.apk"^)
echo                 
echo                 # Build command based on whether keystore is provided
echo                 if self.keystore_path:
echo                     cmd = [
echo                         "java", "-jar", self.bundletool_path,
echo                         "build-apks", "--bundle", aab_file,
echo                         "--output", apks_output,
echo                         "--mode=universal",
echo                         "--ks", self.keystore_path,
echo                         "--ks-pass", f"pass:{self.keystore_pass.get(^)}"
echo                     ]
echo                 else:
echo                     # Without keystore - will use debug keystore if available
echo                     cmd = [
echo                         "java", "-jar", self.bundletool_path,
echo                         "build-apks", "--bundle", aab_file,
echo                         "--output", apks_output,
echo                         "--mode=universal"
echo                     ]
echo                 
echo                 self.log(f"Building APKS for {file_name}..."^)
echo                 try:
echo                     process = subprocess.run(cmd, check=True, capture_output=True, text=True^)
echo                     
echo                     # Extract universal APK from the generated APKS
echo                     extract_dir = os.path.join(self.output_dir, f"extracted_{base_name}"^)
echo                     os.makedirs(extract_dir, exist_ok=True^)
echo                     
echo                     extract_cmd = [
echo                         "java", "-jar", self.bundletool_path,
echo                         "extract-apks",
echo                         "--apks", apks_output,
echo                         "--output-dir", extract_dir
echo                     ]
echo                     
echo                     self.log("Extracting universal APK..."^)
echo                     subprocess.run(extract_cmd, check=True, capture_output=True, text=True^)
echo                     
echo                     # Move the universal APK to the desired output location
echo                     universal_apk = os.path.join(extract_dir, "universal.apk"^)
echo                     if os.path.exists(universal_apk^):
echo                         # If file already exists, replace it
echo                         if os.path.exists(apk_output^):
echo                             os.remove(apk_output^)
echo                         os.rename(universal_apk, apk_output^)
echo                         self.log(f"Successfully created: {apk_output}"^)
echo                         success_count += 1
echo                     else:
echo                         self.log(f"ERROR: Universal APK not found in extracted files for {file_name}"^)
echo                     
echo                     # Clean up temporary files
echo                     try:
echo                         if os.path.exists(apks_output^):
echo                             os.remove(apks_output^)
echo                         import shutil
echo                         if os.path.exists(extract_dir^):
echo                             shutil.rmtree(extract_dir^)
echo                     except Exception as e:
echo                         self.log(f"Warning during cleanup: {str(e^)}"^)
echo                 
echo                 except subprocess.CalledProcessError as e:
echo                     self.log(f"ERROR converting {file_name}: {e}"^)
echo                     self.log(f"Error details: {e.stderr}"^)
echo                 
echo                 # Update progress bar
echo                 self.progress_bar["value"] += progress_step
echo                 self.root.update_idletasks(^)
echo             
echo             # Conversion completed
echo             self.progress_bar["value"] = 100
echo             if success_count == len(self.aab_files^):
echo                 self.update_status(f"Conversion completed. {success_count} files converted successfully."^)
echo                 messagebox.showinfo("Success", f"All {success_count} AAB files converted successfully!"^)
echo             else:
echo                 self.update_status(f"Conversion completed with issues. {success_count}/{len(self.aab_files^)} files converted."^)
echo                 messagebox.showwarning("Partial Success", 
echo                     f"{success_count} out of {len(self.aab_files^)} AAB files converted successfully. Check the log for details."^)
echo             
echo         except Exception as e:
echo             self.log(f"ERROR: {str(e^)}"^)
echo             messagebox.showerror("Error", f"An error occurred during conversion: {str(e^)}"^)
echo             self.update_status("Conversion failed."^)
echo         
echo         finally:
echo             # Re-enable UI elements
echo             self.root.config(cursor=""^)
echo             for widget in self.root.winfo_children(^):
echo                 if isinstance(widget, ttk.Button^):
echo                     widget.config(state=tk.NORMAL^)
echo.
echo.
echo def resource_path(relative_path^):
echo     """Get absolute path to resource, works for dev and for PyInstaller"""
echo     try:
echo         # PyInstaller creates a temp folder and stores path in _MEIPASS
echo         base_path = sys._MEIPASS
echo     except Exception:
echo         base_path = os.path.abspath("."^)
echo     
echo     return os.path.join(base_path, relative_path^)
echo.
echo.
echo if __name__ == "__main__":
echo     root = tk.Tk(^)
echo     app = AABtoAPKConverter(root^)
echo     root.mainloop(^)
) > aab_to_apk_converter.py

echo Installing required packages...
pip install pyinstaller > nul

echo Creating executable...
pyinstaller --onefile --windowed aab_to_apk_converter.py

echo.
echo Executable created successfully!
echo.
echo You can find the executable in the 'temp\dist' folder.
echo Copy 'aab_to_apk_converter.exe' to your desired location.
echo.
echo Remember: Users will still need Java installed and bundletool.jar available.

cd ..
pause
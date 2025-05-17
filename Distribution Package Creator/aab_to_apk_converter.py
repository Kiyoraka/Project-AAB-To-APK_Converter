import os
import subprocess
import sys
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from threading import Thread


class AABtoAPKConverter:
    def __init__(self, root):
        self.root = root
        self.root.title("AAB to APK Converter")
        self.root.geometry("700x500")
        self.root.resizable(True, True)
        
        # Set minimum window size
        self.root.minsize(600, 400)
        
        # Variables
        self.aab_files = []
        self.output_dir = ""
        self.bundletool_path = ""
        self.keystore_path = ""
        self.keystore_pass = tk.StringVar(value="android")
        self.java_installed = False
        
        # Create GUI elements
        self.create_widgets()
        
        # Check for Java installation
        self.java_installed = self.check_java()
        
        # Check for bundletool.jar in the application directory
        self.check_bundletool()

    def create_widgets(self):
        # Create main frame with padding
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title_label = ttk.Label(main_frame, text="AAB to APK Converter", font=("Helvetica", 16, "bold"))
        title_label.pack(pady=10)
        
        # Input section
        input_frame = ttk.LabelFrame(main_frame, text="Input Files", padding="10")
        input_frame.pack(fill=tk.X, pady=5)
        
        # AAB files selection
        aab_frame = ttk.Frame(input_frame)
        aab_frame.pack(fill=tk.X, pady=5)
        
        self.aab_label = ttk.Label(aab_frame, text="No AAB files selected")
        self.aab_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        aab_btn = ttk.Button(aab_frame, text="Select AAB Files", command=self.select_aab_files)
        aab_btn.pack(side=tk.RIGHT)
        
        # Output directory selection
        output_frame = ttk.Frame(input_frame)
        output_frame.pack(fill=tk.X, pady=5)
        
        self.output_label = ttk.Label(output_frame, text="No output directory selected")
        self.output_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        output_btn = ttk.Button(output_frame, text="Select Output Directory", command=self.select_output_dir)
        output_btn.pack(side=tk.RIGHT)
        
        # Tools section
        tools_frame = ttk.LabelFrame(main_frame, text="Tools Configuration", padding="10")
        tools_frame.pack(fill=tk.X, pady=5)
        
        # Bundletool selection
        bundletool_frame = ttk.Frame(tools_frame)
        bundletool_frame.pack(fill=tk.X, pady=5)
        
        self.bundletool_label = ttk.Label(bundletool_frame, text="No bundletool.jar selected")
        self.bundletool_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        bundletool_btn = ttk.Button(bundletool_frame, text="Select bundletool.jar", command=self.select_bundletool)
        bundletool_btn.pack(side=tk.RIGHT)
        
        # Keystore selection
        keystore_frame = ttk.Frame(tools_frame)
        keystore_frame.pack(fill=tk.X, pady=5)
        
        self.keystore_label = ttk.Label(keystore_frame, text="No keystore selected (optional)")
        self.keystore_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        keystore_btn = ttk.Button(keystore_frame, text="Select Keystore", command=self.select_keystore)
        keystore_btn.pack(side=tk.RIGHT)
        
        # Keystore password
        pass_frame = ttk.Frame(tools_frame)
        pass_frame.pack(fill=tk.X, pady=5)
        
        ttk.Label(pass_frame, text="Keystore Password:").pack(side=tk.LEFT)
        pass_entry = ttk.Entry(pass_frame, textvariable=self.keystore_pass, show="*")
        pass_entry.pack(side=tk.LEFT, padx=5)
        
        # Convert button
        convert_btn = ttk.Button(main_frame, text="Convert AAB to APK", command=self.start_conversion, style="Accent.TButton")
        convert_btn.pack(pady=10)
        
        # Create custom style for the convert button
        style = ttk.Style()
        style.configure("Accent.TButton", font=("Helvetica", 12, "bold"))
        
        # Progress bar
        self.progress_bar = ttk.Progressbar(main_frame, mode="determinate")
        self.progress_bar.pack(fill=tk.X, pady=5)
        
        # Log area
        log_frame = ttk.LabelFrame(main_frame, text="Conversion Log", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True, pady=5)
        
        # Scrollbar for log
        scrollbar = ttk.Scrollbar(log_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Log text widget
        self.log_text = tk.Text(log_frame, height=10, wrap=tk.WORD, yscrollcommand=scrollbar.set)
        self.log_text.pack(fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.log_text.yview)
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(fill=tk.X, pady=(5, 0))

    def check_java(self):
        try:
            result = subprocess.run(["java", "-version"], check=True, capture_output=True, text=True, stderr=subprocess.STDOUT)
            # Java version output typically goes to stderr
            version_output = result.stderr if result.stderr else result.stdout
            
            # Extract version information
            import re
            version_match = re.search(r'version "([^"]+)"', version_output)
            if version_match:
                version = version_match.group(1)
                self.log(f"Java detected: version {version}")
                return True
            else:
                self.log("Java detected but couldn't determine version.")
                return True
                
        except (subprocess.SubprocessError, FileNotFoundError):
            self.show_java_missing_dialog()
            return False
    
    def check_bundletool(self):
        """Check if bundletool.jar exists in the same directory as the application"""
        # Get the application directory (works with PyInstaller)
        app_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
        bundletool_path = os.path.join(app_dir, "bundletool.jar")
        
        if os.path.exists(bundletool_path):
            self.bundletool_path = bundletool_path
            self.bundletool_label.config(text=os.path.basename(bundletool_path))
            self.log(f"Found bundletool.jar in application directory: {bundletool_path}")
            return True
        else:
            self.log("No bundletool.jar found in application directory.")
            return False
    
    def show_java_missing_dialog(self):
        java_dialog = tk.Toplevel(self.root)
        java_dialog.title("Java Not Found")
        java_dialog.geometry("500x320")
        java_dialog.resizable(False, False)
        java_dialog.transient(self.root)
        java_dialog.grab_set()
        
        # Center the dialog
        java_dialog.geometry("+%d+%d" % (
            self.root.winfo_rootx() + self.root.winfo_width()//2 - 250,
            self.root.winfo_rooty() + self.root.winfo_height()//2 - 160
        ))
        
        # Warning icon
        warning_frame = ttk.Frame(java_dialog)
        warning_frame.pack(pady=(20, 0))
        
        # Use Unicode warning symbol as we don't have image support in this example
        warning_label = ttk.Label(warning_frame, text="⚠️", font=("Helvetica", 48))
        warning_label.pack()
        
        # Message
        message_frame = ttk.Frame(java_dialog, padding=20)
        message_frame.pack(fill=tk.BOTH, expand=True)
        
        ttk.Label(message_frame, text="Java is not installed or not found!", 
                 font=("Helvetica", 12, "bold")).pack(pady=(0, 10))
        
        message_text = "This application requires Java to convert AAB files to APK.\n\n" + \
                      "Please install Java Development Kit (JDK) 8 or higher."
        ttk.Label(message_frame, text=message_text, wraplength=400).pack()
        
        # Download links
        link_frame = ttk.Frame(message_frame)
        link_frame.pack(pady=10)
        
        ttk.Label(link_frame, text="Download from:").pack(side=tk.LEFT)
        
        # Create hyperlink style labels
        link_style = ttk.Style()
        link_style.configure("Link.TLabel", foreground="blue", font=("Helvetica", 10, "underline"))
        
        adoptium_link = ttk.Label(link_frame, text="Adoptium", style="Link.TLabel", cursor="hand2")
        adoptium_link.pack(side=tk.LEFT, padx=5)
        adoptium_link.bind("<Button-1>", lambda e: self.open_url("https://adoptium.net/"))
        
        oracle_link = ttk.Label(link_frame, text="Oracle", style="Link.TLabel", cursor="hand2")
        oracle_link.pack(side=tk.LEFT, padx=5)
        oracle_link.bind("<Button-1>", lambda e: self.open_url("https://www.oracle.com/java/technologies/downloads/"))
        
        # Buttons
        button_frame = ttk.Frame(java_dialog)
        button_frame.pack(pady=20)
        
        ttk.Button(button_frame, text="Check Again", command=lambda: self.recheck_java(java_dialog)).pack(side=tk.LEFT, padx=10)
        ttk.Button(button_frame, text="Continue Anyway", command=java_dialog.destroy).pack(side=tk.LEFT, padx=10)
        
        self.log("ERROR: Java not found. Please install Java to continue.")
    
    def open_url(self, url):
        """Open URL in default browser"""
        import webbrowser
        webbrowser.open(url)
    
    def recheck_java(self, dialog):
        """Recheck if Java is installed after user potentially installed it"""
        if self.check_java():
            dialog.destroy()
            messagebox.showinfo("Java Detected", "Java has been successfully detected on your system.")
        # If Java is still not found, the check_java method will show the dialog again

    def select_aab_files(self):
        files = filedialog.askopenfilenames(
            title="Select AAB Files",
            filetypes=[("Android App Bundle", "*.aab"), ("All Files", "*.*")]
        )
        if files:
            self.aab_files = files
            if len(files) == 1:
                self.aab_label.config(text=os.path.basename(files[0]))
            else:
                self.aab_label.config(text=f"{len(files)} AAB files selected")
            self.log(f"Selected {len(files)} AAB file(s)")

    def select_output_dir(self):
        directory = filedialog.askdirectory(title="Select Output Directory")
        if directory:
            self.output_dir = directory
            self.output_label.config(text=directory)
            self.log(f"Output directory set to: {directory}")

    def select_bundletool(self):
        file = filedialog.askopenfilename(
            title="Select bundletool.jar",
            filetypes=[("JAR files", "*.jar"), ("All Files", "*.*")]
        )
        if file:
            self.bundletool_path = file
            self.bundletool_label.config(text=os.path.basename(file))
            self.log(f"Bundletool set to: {file}")

    def select_keystore(self):
        file = filedialog.askopenfilename(
            title="Select Keystore",
            filetypes=[("Keystore files", "*.keystore;*.jks"), ("All Files", "*.*")]
        )
        if file:
            self.keystore_path = file
            self.keystore_label.config(text=os.path.basename(file))
            self.log(f"Keystore set to: {file}")

    def log(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        print(message)  # Also print to console for debugging

    def update_status(self, message):
        self.status_var.set(message)
        self.root.update_idletasks()

    def validate_inputs(self):
        if not self.aab_files:
            messagebox.showwarning("No Input", "Please select at least one AAB file.")
            return False
        
        if not self.output_dir:
            messagebox.showwarning("No Output", "Please select an output directory.")
            return False
        
        if not self.bundletool_path:
            messagebox.showwarning("No Bundletool", "Please select bundletool.jar file.")
            return False
        
        if not self.java_installed:
            result = messagebox.askokcancel(
                "Java Not Detected", 
                "Java is required for conversion. The process will likely fail without Java installed. Continue anyway?"
            )
            if not result:
                return False
        
        # If no keystore is selected, warn the user but allow them to proceed
        if not self.keystore_path:
            result = messagebox.askokcancel(
                "No Keystore", 
                "No keystore selected. The conversion may fail without a keystore. Continue anyway?"
            )
            if not result:
                return False
        
        return True

    def start_conversion(self):
        if not self.validate_inputs():
            return
        
        # Disable UI elements during conversion
        self.root.config(cursor="wait")
        for widget in self.root.winfo_children():
            if isinstance(widget, ttk.Button):
                widget.config(state=tk.DISABLED)
        
        # Reset progress bar
        self.progress_bar["value"] = 0
        total_files = len(self.aab_files)
        progress_step = 100 / total_files if total_files > 0 else 0
        
        # Start conversion in a separate thread to keep UI responsive
        conversion_thread = Thread(target=self.perform_conversion, args=(progress_step,))
        conversion_thread.daemon = True
        conversion_thread.start()

    def perform_conversion(self, progress_step):
        try:
            self.log("Starting conversion process...")
            self.update_status("Converting...")
            
            success_count = 0
            for i, aab_file in enumerate(self.aab_files):
                file_name = os.path.basename(aab_file)
                base_name = os.path.splitext(file_name)[0]
                self.log(f"Processing file {i+1}/{len(self.aab_files)}: {file_name}")
                
                # Create command for bundletool
                apks_output = os.path.join(self.output_dir, f"{base_name}.apks")
                apk_output = os.path.join(self.output_dir, f"{base_name}.apk")
                
                # Build command based on whether keystore is provided
                if self.keystore_path:
                    cmd = [
                        "java", "-jar", self.bundletool_path,
                        "build-apks", "--bundle", aab_file,
                        "--output", apks_output,
                        "--mode=universal",
                        "--ks", self.keystore_path,
                        "--ks-pass", f"pass:{self.keystore_pass.get()}"
                    ]
                else:
                    # Without keystore - will use debug keystore if available
                    cmd = [
                        "java", "-jar", self.bundletool_path,
                        "build-apks", "--bundle", aab_file,
                        "--output", apks_output,
                        "--mode=universal"
                    ]
                
                self.log(f"Building APKS for {file_name}...")
                try:
                    process = subprocess.run(cmd, check=True, capture_output=True, text=True)
                    
                    # Extract universal APK from the generated APKS
                    extract_dir = os.path.join(self.output_dir, f"extracted_{base_name}")
                    os.makedirs(extract_dir, exist_ok=True)
                    
                    extract_cmd = [
                        "java", "-jar", self.bundletool_path,
                        "extract-apks",
                        "--apks", apks_output,
                        "--output-dir", extract_dir
                    ]
                    
                    self.log("Extracting universal APK...")
                    subprocess.run(extract_cmd, check=True, capture_output=True, text=True)
                    
                    # Move the universal APK to the desired output location
                    universal_apk = os.path.join(extract_dir, "universal.apk")
                    if os.path.exists(universal_apk):
                        # If file already exists, replace it
                        if os.path.exists(apk_output):
                            os.remove(apk_output)
                        os.rename(universal_apk, apk_output)
                        self.log(f"Successfully created: {apk_output}")
                        success_count += 1
                    else:
                        self.log(f"ERROR: Universal APK not found in extracted files for {file_name}")
                    
                    # Clean up temporary files
                    try:
                        if os.path.exists(apks_output):
                            os.remove(apks_output)
                        import shutil
                        if os.path.exists(extract_dir):
                            shutil.rmtree(extract_dir)
                    except Exception as e:
                        self.log(f"Warning during cleanup: {str(e)}")
                
                except subprocess.CalledProcessError as e:
                    self.log(f"ERROR converting {file_name}: {e}")
                    self.log(f"Error details: {e.stderr}")
                
                # Update progress bar
                self.progress_bar["value"] += progress_step
                self.root.update_idletasks()
            
            # Conversion completed
            self.progress_bar["value"] = 100
            if success_count == len(self.aab_files):
                self.update_status(f"Conversion completed. {success_count} files converted successfully.")
                messagebox.showinfo("Success", f"All {success_count} AAB files converted successfully!")
            else:
                self.update_status(f"Conversion completed with issues. {success_count}/{len(self.aab_files)} files converted.")
                messagebox.showwarning("Partial Success", 
                    f"{success_count} out of {len(self.aab_files)} AAB files converted successfully. Check the log for details.")
            
        except Exception as e:
            self.log(f"ERROR: {str(e)}")
            messagebox.showerror("Error", f"An error occurred during conversion: {str(e)}")
            self.update_status("Conversion failed.")
        
        finally:
            # Re-enable UI elements
            self.root.config(cursor="")
            for widget in self.root.winfo_children():
                if isinstance(widget, ttk.Button):
                    widget.config(state=tk.NORMAL)


def resource_path(relative_path):
    """Get absolute path to resource, works for dev and for PyInstaller"""
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    
    return os.path.join(base_path, relative_path)


if __name__ == "__main__":
    root = tk.Tk()
    app = AABtoAPKConverter(root)
    root.mainloop()
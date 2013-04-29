# Duet Bootstrap
#
# By Alex McLain <alex@alexmclain.com>
#
# This script was designed to run on Ruby v2.0.0
# http://www.ruby-lang.org/en/downloads/
#
# OVERVIEW
#
#	This script generates a NetLinx workspace and source code to start
#	up a Duet module. It is intended to be used when the entire AMX
#	system has been programmed in Duet.
#
#	This script will generate a workspace and source file in the
#	working directory. It will also compile the generated source
#	code if the NetLinx compiler executable is found.
#
# CONFIGURATION
#
#	It is recommended, although not required, to add this script to
#	your operating system's PATH environment variable so that the
#	script can be called from within the folder of a Duet project.
#	There is plenty of information on the internet on how to do this.
#
#	If you would like to change the default AMX master that will be
#	used when generating workspaces, open the NetLinx Workspace file
#	located at template/template.apw. Modify the communication
#	settings, save the workspace, and close NetLinx Studio.
#
# EXECUTION
#
#	This script will run on many different operating systems.
#
#	On Windows, the fastest and easiest way to use this script is
#	through the command line. Open Windows Explorer and browse
#	to the folder of your compiled Duet .jar file. With no file
#	selected, hold shift and right-click in the empty space of
#	the file browser pane, then select "Open command window here"
#	from the context menu.
#
#	Run this script and pass the Duet module as a parameter in
#	the file path. Pressing the tab key will auto-complete the
#	file name.
#	
#	Example: >duet-bootstrap My_Duet_File_dr1_0_0.jar

require 'rexml/document'

templatePath = "#{File.dirname(__FILE__)}/template"

params = Hash.new

# Initialize parameters.
params[:projectName]	= ''
params[:duetModuleName] = ''
params[:duetModulePath] = ''

# Make sure Duet module file was passed to the script.
if ARGV[0].nil?
	puts 'No Duet module was specified.'
	exit
end

params[:duetModulePath] = ARGV[0].strip

# Check file extension.
unless File.extname(params[:duetModulePath]).downcase == '.jar'
	puts 'Input file was not a Duet file.'
	exit
end

# Parse Duet module name.
params[:duetModuleName] = File.basename(params[:duetModulePath], '.jar')
#params[:duetModuleName] = params[:duetModulePath][/(.*)_dr[0-9]+/, 1]
params[:projectName] = params[:duetModuleName][/(.*)_dr[0-9]+/, 1].gsub(/_/, ' ')

# Import existing AMX workspace template.
workspaceTemplate = File.open("#{templatePath}/template.apw", 'r')
xml = REXML::Document.new(workspaceTemplate)

# Rename the workspace.
xml.elements.each('/Workspace/Identifier') do |identifier|
	identifier.text = params[:projectName]
	break
end

# Rename the project.
xml.elements.each('/Workspace/Project/Identifier') do |identifier|
	identifier.text = params[:projectName]
	break
end

# Rename the system.
xml.elements.each('/Workspace/Project/System/Identifier') do |identifier|
	identifier.text = params[:projectName]
end

# Delete all links to files in the workspace's system. The script
# will regenerate them.
xml.elements.delete_all('/Workspace/Project/System/File')

# Add file nodes.
xml.elements.each('/Workspace/Project/System') do |e|
	
	# Add Duet file.
	fileElement = e.add_element('File')
	fileElement.add_attributes('CompileType' => 'None', 'Type' => 'DUET')
	
	identifier = fileElement.add_element('Identifier')
	identifier.text = params[:duetModuleName]

	filePathName = fileElement.add_element('FilePathName')
	filePathName.text = params[:duetModulePath]

	# Add NetLinx file.
	fileElement = e.add_element('File')
	fileElement.add_attributes('CompileType' => 'Netlinx', 'Type' => 'MasterSrc')

	identifier = fileElement.add_element('Identifier')
	identifier.text = params[:projectName]

	filePathName = fileElement.add_element('FilePathName')
	filePathName.text = "#{params[:projectName]}.axs"
	
	break
end


File.open("#{params[:projectName]}.apw", 'w') do |file|
	file << xml
end


# Import NetLinx source code file template.
template = File.open("#{templatePath}/template.axs", 'r').read

template.gsub!(/%%_PROJECT_NAME_%%/, params[:projectName])
template.gsub!(/%%_MODULE_NAME_%%/, params[:duetModuleName])

File.open("#{params[:projectName]}.axs", 'w') do |file|
	file << template
end

puts 'Generated project.'


# Check for NetLinx compiler.
compilerPath = 'C:\Program Files (x86)\Common Files\AMXShare\COM\nlrc.exe'

canCompile = File.exists?(compilerPath)
unless canCompile
	# Use path for 32-bit O/S and try again.
	compilerPath = 'C:\Program Files\Common Files\AMXShare\COM\nlrc.exe'

	canCompile = File.exists?(compilerPath)
	unless canCompile
		puts 'NetLinx compiler not found. Can\'t auto-compile.'
	end
end

# Execute NetLinx compiler.
if canCompile
	system("\"#{compilerPath}\" \"#{File.absolute_path("#{params[:projectName]}.axs")}\"")
end

puts 'Done.'


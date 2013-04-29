# Duet Bootstrap
#
# By Alex McLain <alex@alexmclain.com>
#
# This script was designed to run on Ruby v2.0.0
#
# This script generates a NetLinx workspace and source code
# to start up a Duet module. It is intended to be used when
# the entire AMX system has been programmed in Duet.
#
# On Windows, open the command line by holding shift and
# right clicking in Windows Explorer. Select "Open command
# window here". Run this script and pass the Duet module
# as a parameter in the file path.
# Example: > duet-bootstrap.rb My_Duet_File_dr1_0_0.jar

require 'rexml/document'

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
workspaceTemplate = File.open('template/template.apw', 'r')
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
template = File.open('template/template.axs', 'r').read

template.gsub!(/%%_PROJECT_NAME_%%/, params[:projectName])
template.gsub!(/%%_MODULE_NAME_%%/, params[:duetModuleName])

File.open("#{params[:projectName]}.axs", 'w') do |file|
	file << template
end

puts 'Done.'


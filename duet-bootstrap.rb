# Duet Bootstrap
#
# By Alex McLain <alex@alexmclain.com>
#
# This script was designed to run on Ruby v2.0.0
#
# This script generates a NetLinx workspace and source code
# to start up a Duet module. It is intended to be used when
# the entire AMX system has been programmed in Duet.

require 'rexml/document'

params = Hash.new

#### TEST ####
params[:duetModuleName] = 'ModuleNameHere'
params[:duetModulePath] = 'duetModuleFile.jar'
##############

# Import existing AMX workspace template.
workspaceTemplate = File.open('template/template.apw', 'r')
xml = REXML::Document.new(workspaceTemplate)

# Prompt user for the project name.
# TODO: Script can determine name from Duet module. ///////////////////
print 'Project name: '
@projectName = gets.strip

if @projectName.nil? || @projectName.empty?; exit end

# Rename the workspace.
xml.elements.each('/Workspace/Identifier') do |identifier|
	identifier.text = @projectName
	break
end

# Rename the project.
xml.elements.each('/Workspace/Project/Identifier') do |identifier|
	identifier.text = @projectName
	break
end

# Rename the system.
xml.elements.each('/Workspace/Project/System/Identifier') do |identifier|
	identifier.text = @projectName
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
	identifier.text = @projectName

	filePathName = fileElement.add_element('FilePathName')
	filePathName.text = "#{@projectName}.axs"
	
	break
end


File.open("#{@projectName}.apw", 'w') do |file|
	file << xml
end

# Import NetLinx source code file template.
template = File.open('template/template.axs', 'r').read

template.gsub!(/%%_PROJECT_NAME_%%/, @projectName)
template.gsub!(/%%_MODULE_NAME_%%/, params[:duetModuleName])

File.open("#{@projectName}.axs", 'w') do |file|
	file << template
end


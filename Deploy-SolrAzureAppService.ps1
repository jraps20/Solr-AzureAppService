Param(
    $solrVersion
)

$solrName = "solr-$solrVersion"

Write-Output 'Setting Security to TLS 1.2'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output 'Prevent the progress meter from trying to access the console'
$global:progressPreference = 'SilentlyContinue'

$siteRoot = "D:\home\site\wwwroot"

Write-Output "Downloading Solr $solrVersion zip to D:\home\site"

$downloadSource = "https://archive.apache.org/dist/lucene/solr/$solrVersion/$solrName.zip"
Invoke-WebRequest -Uri $downloadSource -UseBasicParsing -OutFile "..\solr.zip"

Write-Output "Expanding Solr zip at D:\home\site directory as D:\home\site\$solrName"
Expand-Archive "..\solr.zip" -DestinationPath "..\"

Write-Output "Copying contents of D:\home\site\$solrName to D:\home\site\wwwroot"

xcopy "..\$solrName\*" "..\wwwroot" /S /Y

Write-Output 'Copy web.config from repository to D:\home\site\wwwroot'
xcopy web.config ..\wwwroot /Y

Write-Output 'Copy default configset as sitecore'
xcopy "..\wwwroot\server\solr\configsets\_default\*.*" "..\wwwroot\server\solr\configsets\sitecore\*" /s/h/e/k/f/c/Y

Write-Output 'Modifying uniqueKey of sitecore configset'

$xml = New-Object XML
$path = "..\wwwroot\server\solr\configsets\sitecore\conf\managed-schema"
$xml.Load($path)

$uniqueKey =  $xml.SelectSingleNode("//uniqueKey")
$uniqueKey.InnerText = "_uniqueid"

#$field = $xml.CreateElement("field")
#$field.SetAttribute("name", "_uniqueid")
#$field.SetAttribute("type", "string")
#$field.SetAttribute("indexed", "true")
#$field.SetAttribute("required", "true")
#$field.SetAttribute("stored", "true")

#$xml.DocumentElement.AppendChild($field)

$xml.Save($path)

$sitecoreCores = @(
	"sitecore_analytics_index", 
    "sitecore_core_index", 
    "sitecore_fxm_master_index", 
	"sitecore_fxm_web_index", 
	"sitecore_list_index", 
    "sitecore_marketing_asset_index_master", 
    "sitecore_marketing_asset_index_web", 
	"sitecore_marketingdefinitions_master", 
	"sitecore_marketingdefinitions_web", 
    "sitecore_master_index", 
	"sitecore_suggested_test_index", 
	"sitecore_testing_index", 
	"sitecore_web_index", 
    "social_messages_master", 
	"social_messages_web"
)

foreach ($coreName in $sitecoreCores) {
	Write-Output "Creating $coreName index"
	New-Item "..\wwwroot\server\solr\" -Name "$coreName" -ItemType "directory"
	New-Item "..\wwwroot\server\solr\$coreName" -Name "data" -ItemType "directory"
	xcopy "..\wwwroot\server\solr\configsets\sitecore\conf\*" "..\wwwroot\server\solr\$coreName" /S /Y
}
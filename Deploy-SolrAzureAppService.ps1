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
$usingDefault = $false
if(Test-Path "..\wwwroot\server\solr\configsets\_default" -PathType Any){
	$usingDefault = $true
	xcopy "..\wwwroot\server\solr\configsets\_default\*.*" "..\wwwroot\server\solr\configsets\sitecore\*" /s/h/e/k/f/c/Y
}
else{
	xcopy "..\wwwroot\server\solr\configsets\basic_configs\*.*" "..\wwwroot\server\solr\configsets\sitecore\*" /s/h/e/k/f/c/Y
}


Write-Output 'Modifying uniqueKey of sitecore configset'

$xml = New-Object XML
$path = "..\wwwroot\server\solr\configsets\sitecore\conf\managed-schema"
$xml.Load($path)

$uniqueKey =  $xml.SelectSingleNode("//uniqueKey")
$uniqueKey.InnerText = "_uniqueid"

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
	xcopy "..\wwwroot\server\solr\configsets\sitecore\conf\*" "..\wwwroot\server\solr\$coreName\conf\*" /S /Y
	New-Item "..\wwwroot\server\solr\$coreName\core.properties"
	Set-Content "..\wwwroot\server\solr\$coreName\core.properties" "name=$coreName`r`nupdate.autoCreateFields=false`r`ndataDir=data"
}

$xdbCores = @(
	"xdb", 
    "xdb_rebuild"
)

foreach ($coreName in $xdbCores) {
	Write-Output "Creating $coreName index"
	New-Item "..\wwwroot\server\solr\" -Name "$coreName" -ItemType "directory"
	New-Item "..\wwwroot\server\solr\$coreName" -Name "data" -ItemType "directory"

	if($usingDefault){
		xcopy "..\wwwroot\server\solr\configsets\_default\conf\*" "..\wwwroot\server\solr\$coreName\conf\*" /S /Y
	}
	else{
		xcopy "..\wwwroot\server\solr\configsets\basic_configs\conf\*" "..\wwwroot\server\solr\$coreName\conf\*" /S /Y
	}

	New-Item "..\wwwroot\server\solr\$coreName\core.properties"
	Set-Content "..\wwwroot\server\solr\$coreName\core.properties" "name=$coreName`r`ndataDir=data"
}
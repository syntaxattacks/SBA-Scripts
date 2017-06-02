function Get-ClipboardText()
{
	$command =
	{
	    add-type -an system.windows.forms
	    [System.Windows.Forms.Clipboard]::GetText()
	}
	powershell -sta -noprofile -command $command
}

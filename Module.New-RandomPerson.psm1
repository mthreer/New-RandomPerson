# Installationg/Usage: 
# Import-Module Module.New-RandomPerson.psm1

function New-RandomPerson {
    <#
.SYNOPSIS
    This script will generate new swedish random person(s) using fejka.nu for use with mockups or demos
.EXAMPLE
    PS C:\> New-RandomPerson -Count 3 -Gender Male

    This will generate 3 random male persons
.PARAMETER Count
    Number of fake persons to be generated
.PARAMETER MinimumAge
    Set the desired minimum age of the person(s). Possible values: 16-99
.PARAMETER MaximumAge
    Set the desired maximum age of the person(s). Possible values: 16-99
.PARAMETER Gender
    Set the desired gender of the random person(s). Possible values: Male or Female.
.NOTES
    MIT License

    Copyright (C) 2021 Niklas J. MacDowall. All rights reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the ""Software""), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    AUTHOR: Niklas J. MacDowall (niklasjumlin [at] gmail [dot] com)
    LASTEDIT: Nov 02, 2021
.LINK
    http://blog.jumlin.com
#>

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        Mandatory = $False, 
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Provide how many random persons that should be generated"
    )]
    [ValidateNotNullorEmpty()]
    [ValidateScript({$_ -ge 1},ErrorMessage="Count value must be greater than {0}")]
    [Int]$Count = 1,
    
    [Parameter(
        Mandatory = $False, 
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Set the desired minimum age of the person(s)"
    )]
    [ValidateScript({$_ -ge 16},ErrorMessage="MinimumAge value must be greater than 16")]
    [ValidateScript({$_ -le 99},ErrorMessage="MinimumAge value must be less than 99")]
    [Int]$MinimumAge = 16,
    
    [Parameter(
        Mandatory = $False, 
        HelpMessage = "Set the desired maximum age of the person(s)"
    )]
    [ValidateScript({$_ -ge 16},ErrorMessage="MaximumAge value must be greater than 16")]
    [ValidateScript({$_ -le 99},ErrorMessage="MaximumAge value must be less than 99")]
    [Int]$MaximumAge = 99,
    
    [Parameter(
        Mandatory = $False, 
        HelpMessage = "If generated password should exclude uppercase letters"
    )]
    [ValidateSet("Male","Female")]
    [String]$Gender,

    [Parameter(
        Mandatory = $False, 
        HelpMessage = "Set the desired email domain for the random person"
    )]
    [ValidateScript({$_ -notlike "*@*"},ErrorMessage="The domain should not include the @-character")]
    [ValidateScript({$_ -match "\b((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}\b"},ErrorMessage="The domain is not in the correct format. See RFC 1035 by IETF.")]
    [String]$Domain
    )

    Begin {
        $Genders = @{
            "Male" = "man"
            "Female" = "woman"
        }
        [string]$baseUrl = "https://fejka.nu?json=1"
        [string]$UrlQuery = '&num=' + $Count + '&age_min=' + $MinimumAge + '&age_max=' + $MaximumAge
        if ($Gender) {
            $UrlQuery = $UrlQuery + '&gender=' + $Genders."$Gender"
        }
        [string]$uri = $baseUrl + $UrlQuery
    }
    Process {
        Try {
            $Request =  Invoke-WebRequest -Method 'Post' -Uri $uri -Headers @{'Content-Type' = "text/json"} -ErrorAction Stop
        }
        Catch {
            $_.Exception.Message
        }
    }
    End {
        if ($Request.Content) {
            if ($Domain) {
                $Request.Content -replace ("fejka.nu","$Domain") | ConvertFrom-Json
            }
            else {
                $Request.Content | ConvertFrom-Json
            }
        }
        else {
            $Request
        }
    }
}
# Description

Notebook with dual GPU(Graphic Processing Unit) often experience poor battery life. This is generally caused by the use of dedicated GPU to run applications when in battery mode. Using dedicated monitor can be another important factor. Notebook without MUX switch had its GPU  hardwired into dedicated GPU, forcing all aplication run in dedicated monitor using the dedicated GPU.

This script aims to improve battery life on laptops with dual graphics cards by resetting the dedicated GPU. By resetting the graphics card, all applications are forced to use the internal GPU.

>**[!WARNING]**
>This script has only been tested for resetting graphics while running office applications such as browsers, messengers, and document processing. If a graphics reset is performed while using applications that require dedicated graphics, such as gaming or rendering, errors may occur.


# Usage Instruction

1. Enable `GPU Activity Icon` in Nvidia Control Panel

Enable `GPU Activity Icon` to monitor which app is using the GPU

![image](https://i.imgur.com/ZVD1i1E.png)

2. Detect your internal monitor name

Run this script on powershell to get internal monitor InstanceId

```
Get-PnpDevice -Status OK | Where-Object  {$_.class -like "Monitor"}
```


![image](https://i.imgur.com/JpqP0Yv.png)

3. Download script

Download this script and open `cylce-gpu.ps1`, edit this variable `$internalDisplayName = "DISPLAY\LEN4*"` using internal monitor `InstanceId` found in previous step

4. Running the script

Righ click on `cycle-gpu.bat` and run as administrator

![image](https://i.imgur.com/dQlCvcB.png)

The script will reset your GPU when no external monitor is connected and running in battery. If you leave the script open it will run indefinitely

![image](https://i.imgur.com/5Dh9tqD.png)

After external GPU is reset , the `GPU Activity Icon` will be grey out meaning no application run on external GPU

# Disclaimer and License
This script is provided "as is", without warranty of any kind, express or implied. Use it at your own risk.

This project is licensed under the terms of the MIT license. The full text of the license can be found in the LICENSE file. By using this script, you agree to the terms and conditions of this license.

The author(s) of this script are not responsible for any damage, data loss, or any other issues that may occur as a result of using this script. Always make sure to backup your data and test the script in a controlled environment before using it in a production setting.


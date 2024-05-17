# iattract
![iattract.png](https://raw.githubusercontent.com/RapidEdwin08/iattract/main/iattract.png )

Menu driven script to convert ES [gamelist.xml] to attractmode [romlist.txt]  
A group effort by SupremeTeam  

NOTE: Script will Overwrite any/all pre-existing attractmode [romlist.txt]  

## INSTALLATION  
***You MUST INSTALL [attractmode] from RetroPie Setup 1st!***  

If you want 1-Run-N-Done:
```bash
curl -sSL https://raw.githubusercontent.com/RapidEdwin08/iattract/main/iattract.sh  | bash  
```

If you want to Put the Script in the retropiemenu [+Icon]:  
```bash
wget https://raw.githubusercontent.com/RapidEdwin08/iattract/main/iattract.sh -P ~/RetroPie/retropiemenu
wget https://raw.githubusercontent.com/RapidEdwin08/iattract/main/iattract.png -P ~/RetroPie/retropiemenu/icons

```

0ptionally you can Add an Entry [+Icon] to your retropiemenu [gamelist.xml]:  
*Example Entry:*  
```
	<game>
		<path>./iattract.sh</path>
		<name>[iattract]</name>
		<desc>Convert ES [gamelist.xml] to attractmode [romlist.txt]</desc>
		<image>./icons/iattract.png</image>
	</game>
```

If you want to GIT it All:  
```bash
cd ~
git clone --depth 1 https://github.com/RapidEdwin08/iattract.git
chmod 755 ~/iattract/iattract.sh
cd ~/iattract && ./iattract.sh

```

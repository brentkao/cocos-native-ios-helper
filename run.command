#!/bin/bash

# 獲取腳本所在目錄的絕對路徑
# 選擇專案路徑
projectPath=$(osascript -e 'tell application "Finder" to return POSIX path of (choose folder with prompt "Select Your Project Folder")')
projectPath="${projectPath%/}" # 移除路徑最後的斜線
echo "專案路徑(project path): $projectPath"

# 檢查專案是否有 cocos creator 的專案(assets/package.json/tsconfig.json)
if [ ! -d "${projectPath}/assets" ] || [ ! -f "${projectPath}/package.json" ] || [ ! -f "${projectPath}/tsconfig.json" ]; then
    echo "檢查錯誤："
    [ ! -d "${projectPath}/assets" ] && echo "/assets 資料夾不存在。"
    [ ! -f "${projectPath}/package.json" ] && echo "package.json 檔案不存在。"
    [ ! -f "${projectPath}/tsconfig.json" ] && echo "tsconfig.json 檔案不存在。"
    exit 1
fi

checkEcho(){
    echo "$1「$2」: $3"
}
readYesNo(){
    read -p "$1?(y/n) " -n 1 -r  
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
       return 1
    fi
}
dividingLine(){
    echo ""
    printf '%*s\n' "$(tput cols)" '' | tr ' ' -
    echo ""
}
dividingLine
echo "可用的 Cocos Creator 版本有:"
versions=("3.8.2" "3.8.1" "3.8.0" "退出(exit)")
select version in ${versions[@]}; do
  case $version in 
  "退出(exit)")
    echo "退出(exit)"
    exit 0
    ;;
    *)
    echo "選擇的版本是：$version"
    # Cocos Creator 的可執行文件路徑
    cocosCreatorPath="/Applications/Cocos/Creator/${version}/CocosCreator.app/Contents/MacOS/CocosCreator"
            if [ -f "$cocosCreatorPath" ]; then
                echo "找到了 Cocos Creator $version 版本"
                readYesNo "是否已有 native/engine/ios 資料夾"
                isNativeFolder=$?
                if [ $isNativeFolder -eq 0 ]; then
                    echo "無需初始化 ios build"
                else
                    echo "開始初始化 native/engine/ios 資料夾"
                "$cocosCreatorPath" --project "$projectPath" --build "platform=ios;debug=true;verbose=true;buildPath=./build;md5Cache=false"
                fi
            else
                echo "未找到 Cocos Creator $version 版本，請檢查是否安裝在預期路徑(/Applications/Cocos/Creator)。"
                echo "尋找指令: find /Applications -name CocosCreator"
                exit 0
            fi
            ;;
    esac
    break # 跳出循环
done

dividingLine
echo "[Start] 設定資料 (native-ios-build-files => navtive -> engine -> ios)"
cd -- "$(dirname "$BASH_SOURCE")"

# Action
readYesNo "use Admob"  # 是否使用 Admob
isUsingAdmob=$?
readYesNo "use Apple-IAP"  # 是否使用 Apple-IAP
isUsingAppleIAP=$?
readYesNo "use Apple-GameCenter"  # 是否使用 Apple-GameCenter
isUsingAppleGameCenter=$?

# 定義目錄和文件名
copyFilesDir="./CopyFiles"
targetFilesDir="native/engine/ios"
#Google
zipFile="GoogleMobileAdsSdkiOS-10.14.0.zip"
GoogleMobilefolderName="GoogleMobileAdsSdkiOS-10.14.0"
AdmobFolderName="Admob"
#Apple
AppleIAPFolderName="AppleIAP"
AppleGameCenterFolderName="AppleGameCenter"

dividingLine
checkEcho "開始檢查" "CopyFiles" "..."
if [ ! -d "$copyFilesDir/$GoogleMobilefolderName" ]; then
    # 確保 ZIP 檔案存在
    if [ -f "./$zipFile" ]; then
        # 解壓縮後的檔案會放在 CopyFiles 目錄下
        echo "目錄 $GoogleMobilefolderName 不存在，開始解壓縮..."
        unzip "$zipFile" -d "$copyFilesDir"
        echo "解壓縮完成。"
    else
        checkEcho "檢查錯誤" "CopyFiles" "ZIP文件 $zipFile 不存在。"
        exit 1
    fi
else
    checkEcho "結束檢查" "CopyFiles" "目錄 $GoogleMobilefolderName 已存在。"
fi
checkEcho "結束檢查" "CopyFiles"

checkEcho "開始覆蓋" "CopyFiles" "..."
echo "初始化所需的基礎資料"

# 必要檔案
cp -R $copyFilesDir/NotifyJSHelper $projectPath/$targetFilesDir

if [ $isUsingAdmob -eq 0 ]; then
    echo "複製 Admob 相關檔案"
    cp -R $copyFilesDir/$GoogleMobilefolderName $projectPath/$targetFilesDir
    cp -R $copyFilesDir/$AdmobFolderName $projectPath/$targetFilesDir
    cp -R $copyFilesDir/AppDelegate.mm $projectPath/$targetFilesDir
    cp -R $copyFilesDir/Info.plist $projectPath/$targetFilesDir
fi

if [ $isUsingAppleIAP -eq 0 ]; then
    echo "複製 Apple-IAP 相關檔案"
    cp -R $copyFilesDir/$AppleIAPFolderName $projectPath/$targetFilesDir
fi

if [ $isUsingAppleGameCenter -eq 0 ]; then
    echo "複製 Apple-GameCenter 相關檔案"
    cp -R $copyFilesDir/$AppleGameCenterFolderName $projectPath/$targetFilesDir
fi

checkEcho "結束覆蓋" "CopyFiles" "$targetFilesDir"

if [ $isNativeFolder -eq 1 ]; then
    echo "移除 Build 目錄的 ios 資料夾($projectPath/build/ios)"
    rm -r $projectPath/build/ios
fi

echo "專案建立完成。"

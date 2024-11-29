#!/bin/bash

# 当前版本：1.0.5

## 参数说明
# git clone "https://github.com/hezhijie0327/Toolkit.git"
# bash ./Toolkit/Git.sh -u "hezhijie0327" -r "Toolkit" -b "main" -d "1" -m "clone"
# bash ./Toolkit/Git.sh -u "hezhijie0327" -r "Toolkit" -e "hezhijie0327@hotmail.com" -f "." -i "Generated by GitHub Actions" -m "push"

## 获取参数
function parse_params() {
    while getopts b:d:e:f:i:m:r:u: opt; do
        case ${opt} in
            b) REPO_BRANCH="${OPTARG}";;
            d) REPO_DEPTH="${OPTARG}";;
            e) USER_EMAIL="${OPTARG}";;
            f) COMMIT_FILE="${OPTARG}";;
            i) COMMIT_INFO="${OPTARG}";;
            m) GIT_MODE="${OPTARG}";;
            r) REPO_NAME="${OPTARG}";;
            u) USER_NAME="${OPTARG}";;
        esac
    done
}

## 检查配置的有效性
function check_configuration() {
    if [ -z "${GIT_MODE}" ]; then
        echo "错误：缺少 GIT_MODE 参数，必须指定 'clone' 或 'push'。"
        exit 1
    elif [ "${GIT_MODE}" != "clone" ] && [ "${GIT_MODE}" != "push" ]; then
        echo "错误：无效的 GIT_MODE 值，必须是 'clone' 或 'push'。"
        exit 1
    fi
    
    if [ -z "${REPO_NAME}" ] || [ -z "${USER_NAME}" ]; then
        echo "错误：缺少 REPO_NAME 或 USER_NAME 参数。"
        exit 1
    fi
    
    # 针对 clone 模式的检查
    if [ "${GIT_MODE}" == "clone" ]; then
        if [ -z "${REPO_BRANCH}" ] || [ -z "${REPO_DEPTH}" ] || ! [[ "${REPO_DEPTH}" =~ ^[0-9]+$ ]]; then
            echo "错误：缺少 REPO_BRANCH 或 REPO_DEPTH 参数，或 REPO_DEPTH 不是有效的数字。"
            exit 1
        fi
    # 针对 push 模式的检查
    elif [ "${GIT_MODE}" == "push" ]; then
        if [ -z "${COMMIT_FILE}" ] || [ -z "${COMMIT_INFO}" ] || [ -z "${USER_EMAIL}" ] || ! [[ "${USER_EMAIL}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            echo "错误：缺少 COMMIT_FILE、COMMIT_INFO 或 USER_EMAIL 参数，或 USER_EMAIL 无效。"
            exit 1
        fi
    fi
}

## 检查是否安装 Git
function check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo "错误：Git 没有安装，请先安装 Git。"
        exit 1
    fi
}

## 克隆仓库
function clone_repo() {
    if [ -d "${REPO_NAME}" ]; then
        echo "警告：${USER_NAME}/${REPO_NAME} 已经存在本地。"
    else
        git clone -b "${REPO_BRANCH}" --depth "${REPO_DEPTH}" "https://github.com/${USER_NAME}/${REPO_NAME}.git"
        if [ $? -eq 0 ]; then
            echo "成功：${USER_NAME}/${REPO_NAME} 已成功克隆。"
        else
            echo "错误：${USER_NAME}/${REPO_NAME} 克隆失败。"
        fi
    fi
}

## 推送更改
function push_changes() {
    if [ -z "$(git status -s)" ]; then
        echo "警告：没有需要提交的更改。"
    else
        git config user.name "${USER_NAME}"
        git config user.email "${USER_EMAIL}"
        git add "${COMMIT_FILE}"
        git commit -m "${COMMIT_INFO}"
        git push --force
        if [ $? -eq 0 ]; then
            echo "成功：${USER_NAME}/${REPO_NAME} 已成功推送。"
        else
            echo "错误：${USER_NAME}/${REPO_NAME} 推送失败。"
        fi
    fi
}

## 主函数
function main() {
    # 解析参数
    parse_params "$@"

    # 检查配置和依赖
    check_configuration
    check_git_installed

    # 根据 GIT_MODE 执行相应操作
    if [ "${GIT_MODE}" == "clone" ]; then
        clone_repo
    elif [ "${GIT_MODE}" == "push" ]; then
        push_changes
    fi
}

# 执行主函数
main "$@"

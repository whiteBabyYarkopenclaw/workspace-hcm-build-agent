#!/bin/bash

# HCM Skill Creator 处理脚本
# 用于验证专家、创建知识库、生成Skill
# 支持动态输入：可一次性提供多个参数

WORKSPACE="/home/beaver/.openclaw/workspace-hcm-build-agent"
EXPERTS_FILE="$WORKSPACE/experts.json"
KNOWLEDGE_BASE="$WORKSPACE/knowledge-base"
SKILLS_DIR="$WORKSPACE/skills"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 解析参数 - 支持动态输入
# 用法: 
#   creator.sh verify ID NAME
#   creator.sh check-auth ID [NAME]       - 只检查ID或ID+NAME
#   creator.sh create-folder NAME DESC EXPERT_ID EXPERT_NAME
#   creator.sh generate-skill NAME DESC EXPERT_ID EXPERT_NAME KNOWLEDGE_PATH
#   creator.sh suggestions NAME DESC
#   creator.sh all ID NAME MODEL_NAME MODEL_DESC  - 一键完成

# 验证专家身份（支持部分输入）
verify_expert_partial() {
    local expert_id="$1"
    local expert_name="$2"
    
    if [ ! -f "$EXPERTS_FILE" ]; then
        echo -e "${RED}错误：专家列表文件不存在${NC}"
        return 1
    fi
    
    # 如果只提供了ID，检查ID是否存在
    if [ -n "$expert_id" ] && [ -z "$expert_name" ]; then
        if grep -q "\"id\":.*\"$expert_id\"" "$EXPERTS_FILE"; then
            echo -e "${BLUE}ID 验证通过，请提供您的姓名${NC}"
            return 2  # 需要更多输入
        else
            echo -e "${RED}错误：专家ID不存在${NC}"
            return 1
        fi
    fi
    
    # 如果只提供了姓名，检查姓名是否存在
    if [ -z "$expert_id" ] && [ -n "$expert_name" ]; then
        if grep -q "\"name\":.*\"$expert_name\"" "$EXPERTS_FILE"; then
            echo -e "${BLUE}姓名验证通过，请提供您的专家ID${NC}"
            return 2
        else
            echo -e "${RED}错误：专家姓名不存在${NC}"
            return 1
        fi
    fi
    
    # 两者都提供了
    if [ -n "$expert_id" ] && [ -n "$expert_name" ]; then
        if grep -q "$expert_id" "$EXPERTS_FILE" && grep -q "$expert_name" "$EXPERTS_FILE"; then
            local id_line=$(grep -n "$expert_id" "$EXPERTS_FILE" | head -1 | cut -d: -f1)
            local name_line=$(grep -n "$expert_name" "$EXPERTS_FILE" | head -1 | cut -d: -f1)
            if [ -n "$id_line" ] && [ -n "$name_line" ]; then
                echo -e "${GREEN}✅ 专家验证通过，欢迎 $expert_name！${NC}"
                return 0
            fi
        fi
        echo -e "${RED}❌ 专家权限未开放，请先申请专家资格${NC}"
        return 1
    fi
    
    # 都没有提供
    echo -e "${YELLOW}请提供您的专家ID和姓名${NC}"
    return 3
}

# 创建知识库文件夹
create_knowledge_folder() {
    local model_name="$1"
    local expert_name="$2"
    local expert_id="$3"
    
    local folder_name="${model_name}-${expert_name}-${expert_id}"
    local folder_path="$KNOWLEDGE_BASE/$folder_name"
    
    mkdir -p "$folder_path"/{基础知识,流程步骤,案例分析,常见问题,工具模板,多媒体}
    
    echo -e "${GREEN}知识库文件夹已创建: $folder_path${NC}"
    echo "$folder_path"
}

# 生成 Skill 文件
generate_skill() {
    local model_name="$1"
    local model_desc="$2"
    local expert_id="$3"
    local expert_name="$4"
    local knowledge_path="$5"
    
    mkdir -p "$SKILLS_DIR"
    
    # 修改为 Markdown 格式（.md）
    local skill_file="$SKILLS_DIR/${model_name}.md"
    
    cat > "$skill_file" << EOF
---
name: $model_name
description: $model_desc
trigger_conditions: 当用户询问${model_name}相关问题时触发
---

# $model_name

本技能由专家 $expert_name (ID: $expert_id) 创建。

# 需能力

请根据专家上传的素材，从知识库中提取并生成具体的需能力项。

## 需要的能力名称1: 待生成

- **需能力描述**: [请根据知识库素材补充]
- **约束条件**:
  - 功能: [该能力要实现的核心功能]
  - 数量: [支持的数量范围]
  - 质量: [质量标准]
  - 交付: [交付格式]
  - 情感: [情感价值]
  - 成本: [成本控制]

## 需要的能力名称2: 待生成

- **需能力描述**: [请根据知识库素材补充]
- **约束条件**:
  - 功能: 
  - 数量: 
  - 质量: 
  - 交付: 
  - 情感: 
  - 成本: 

---

*知识库路径: $knowledge_path*
*生成时间: $(date +"%Y-%m-%d %H:%M:%S")*
EOF

    echo -e "${GREEN}Skill 已生成: $skill_file${NC}"
    echo "$skill_file"
}

# 生成素材上传建议
generate_upload_suggestions() {
    local model_name="$1"
    local model_desc="$2"
    
    echo "======================================"
    echo "📁 素材上传建议"
    echo "======================================"
    echo ""
    echo "模型：【$model_name】"
    echo "描述：$model_desc"
    echo ""
    echo "建议上传素材大类："
    echo "  1. 基础知识类 - 概念定义、原理说明"
    echo "  2. 流程步骤类 - 操作流程、决策树"
    echo "  3. 案例分析类 - 真实案例、场景分析"
    echo "  4. 常见问题类 - FAQ、疑难解答"
    echo "  5. 工具模板类 - 表格、清单、模板"
    echo "  6. 多媒体类 - 图片、视频、音频素材"
    echo ""
    echo "请将素材放入对应的分类文件夹中。"
    echo "======================================"
}

# 主函数
main() {
    local command="$1"
    
    case "$command" in
        verify)
            verify_expert_partial "$2" "$3"
            ;;
        check-auth)
            # 只检查认证状态，不创建任何东西
            verify_expert_partial "$2" "$3"
            ;;
        create-folder)
            create_knowledge_folder "$2" "$3" "$4"
            ;;
        generate-skill)
            generate_skill "$2" "$3" "$4" "$5" "$6"
            ;;
        suggestions)
            generate_upload_suggestions "$2" "$3"
            ;;
        all)
            # 一键完成：认证 + 创建文件夹 + 生成建议 + 生成Skill
            echo -e "${BLUE}=== 一键创建模式 ===${NC}"
            local exp_id="$2"
            local exp_name="$3"
            local model_name="$4"
            local model_desc="$5"
            
            echo -e "\n${YELLOW}1. 验证专家身份...${NC}"
            verify_expert_partial "$exp_id" "$exp_name"
            if [ $? -ne 0 ]; then
                echo -e "${RED}认证失败，终止${NC}"
                exit 1
            fi
            
            echo -e "\n${YELLOW}2. 创建知识库文件夹...${NC}"
            local folder_path=$(create_knowledge_folder "$model_name" "$exp_name" "$exp_id")
            
            echo -e "\n${YELLOW}3. 生成素材上传建议...${NC}"
            generate_upload_suggestions "$model_name" "$model_desc"
            
            echo -e "\n${YELLOW}4. 生成Skill...${NC}"
            generate_skill "$model_name" "$model_desc" "$exp_id" "$exp_name" "$folder_path"
            
            echo -e "\n${GREEN}✅ 完成！Skill 已就绪${NC}"
            ;;
        *)
            echo "用法: $0 {verify|check-auth|create-folder|generate-skill|suggestions|all}"
            echo ""
            echo "示例："
            echo "  $0 verify EXP001 张医生                    # 验证专家"
            echo "  $0 check-auth EXP001                       # 只检查ID"
            echo "  $0 create-folder '中医问诊' 张医生 EXP001  # 创建知识库"
            echo "  $0 suggestions '中医问诊' '帮助用户了解体质' # 生成建议"
            echo "  $0 all EXP001 张医生 '中医问诊' '帮助用户了解体质'  # 一键完成"
            ;;
    esac
}

main "$@"

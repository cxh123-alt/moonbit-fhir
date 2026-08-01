# moonbit-fhir 项目申报书

## 项目名称

moonbit-fhir：MoonBit 医疗互操作 FHIR 工具包

## 项目背景

FHIR 是医疗系统进行患者、检查、用药、就诊、诊断报告等数据交换的主流标准之一。MoonBit 生态正在快速发展，但面向医疗互操作的基础库仍然稀缺。`moonbit-fhir` 选择从最常见、最容易复用的 FHIR JSON 工作流切入，为 MoonBit 使用者提供可验证、可查询、可转换的医疗数据处理基础。

## 目标用户

目标用户包括医疗信息系统开发者、数据治理与质控工程师、教学和测试场景中的 FHIR 初学者，以及希望在 MoonBit 中构建数据交换、校验、转换工具的开发者。

## 核心功能

第一阶段实现 FHIR R4/R5 风格 JSON 资源处理，覆盖 `Patient`、`Observation`、`Medication`、`DiagnosticReport`、`Encounter` 和 `Bundle`。项目提供资源类型识别、结构校验、校验报告、Bundle entry 解析、JSON Pointer 查询、示例数据、资源摘要提取、Observation CSV 行转换，以及 `fhir-validate` 命令行入口。

## 技术方案

项目采用 MoonBit 原生包结构，根包承载公开 API，`cmd/main` 提供 CLI。内部实现围绕 `Json` 值进行轻量建模，避免过早生成庞大 schema，同时保留后续接入 StructureDefinition、FHIRPath、NDJSON 和 terminology binding 的扩展空间。校验结果使用结构化 `ValidationReport` 表达，错误和警告分级，便于 CLI、CI 和上层应用复用。

## 可行性与创新性

该项目范围足够聚焦，可以在黑客松周期内完成可运行版本；同时选题不局限于单个小工具，而是面向 MoonBit 医疗数据生态的长期基础库。与通用 JSON 库不同，本项目沉淀 FHIR 资源语义、Bundle 工作流和医疗数据摘要能力，避免与已有 MoonBit 成熟项目高度重复。

## 工程质量计划

仓库包含 Apache-2.0 License、README、来源说明、Roadmap、示例数据、测试与 GitHub Actions CI。CI 执行 `moon fmt --check`、`moon check --deny-warn`、`moon test --deny-warn`、`moon info --deny-warn`，并运行 CLI 示例，确保项目可构建、可运行、可复现。

## 开发计划

8 月上旬完成核心 API、五类资源校验、Bundle 解析和 CLI；8 月中旬补充示例、README、CI、提交记录和申报材料；后续迭代扩展 NDJSON、FHIRPath 风格查询、profile hooks、R4/R5 差异表与更多资源类型。

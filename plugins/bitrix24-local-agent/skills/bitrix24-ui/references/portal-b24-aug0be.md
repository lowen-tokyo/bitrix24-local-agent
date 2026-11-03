# Verified TEST profile: b24-aug0be.bitrix24.ru

Observed through the Bitrix24 browser UI on 4 November 2026. Verify the live domain, object and current fields before every write. These are synthetic TEST processes; do not assume the same schema on another portal or use their records as customer data.

## Contracts

Process: [ТЕСТ: Договоры локального агента](https://b24-aug0be.bitrix24.ru/crm/type/1040/list/category/0/). Test card: [ID 1](https://b24-aug0be.bitrix24.ru/crm/type/1040/details/1/).

| Field | Type | Required |
| --- | --- | --- |
| Номер договора | Строка | yes |
| Дата договора | Дата | yes |
| Контрагент | Строка | yes |
| Предмет договора | Строка | yes |
| Статус договора | Список | yes |
| Ссылка на проект | Ссылка | no |
| Сумма договора | Деньги | no |
| Дата окончания | Дата | no |
| Файл договора | Файл | no |

Status values: `Черновик`, `На согласовании`, `Подписан`, `Завершён`, `Расторгнут`. The contract number is supplied by the user; no contract numbering robot was configured. The test card uses `ТЕСТ-001` and a link to project 1. Its `Доступно для всех` value was `Нет` when checked. Do not interpret these fields as legally complete contract management.

## Correspondence

Process: [ТЕСТ: Корреспонденция локального агента](https://b24-aug0be.bitrix24.ru/crm/type/1046/list/category/0/). [Robot settings](https://b24-aug0be.bitrix24.ru/crm/type/1046/automation/17/).

| Field | Type | Required |
| --- | --- | --- |
| Направление | Список: `Входящая`, `Исходящая` | yes |
| Тема | Строка | yes |
| Дата документа | Дата | yes |
| Отправитель | Строка | no |
| Получатель | Строка | no |
| Номер документа | Строка | no |
| Файл документа | Файл | no |
| Ссылка на проект | Ссылка | no |
| Ссылка на договор | Ссылка | no |
| Регистрационный номер | Строка | no; robot fills it |

The `Ссылка на договор` field contains a clickable URL to the test contract. An additional generic CRM binding field `Связанный договор` was created but did not find this contract in its picker; it is hidden from the card and list. Do not claim that native CRM relation works. The process settings enable related-element lists, but the relation itself was not verified.

Two native `Изменить элемент` robots run immediately at stage `Начало`. Each requires both its matching direction and an empty `Регистрационный номер`, then writes only that field. Incoming value: `ВХ-{{ID элемента CRM}}`; outgoing value: `ИСХ-{{ID элемента CRM}}`. In this portal the placeholder produced composite IDs such as `T416_5`, so observed registration numbers are `ВХ-T416_5` and `ИСХ-T416_7`, not numeric-only IDs. This uses Bitrix24's assigned element ID and has no last-number read or external service. Human edits to the number and a database-level uniqueness constraint were not tested. Numeric card IDs had gaps, so do not expect a consecutive sequence.

Verified cards: [incoming ID 1](https://b24-aug0be.bitrix24.ru/crm/type/1046/details/1/) `ВХ-T416_1`; [outgoing ID 3](https://b24-aug0be.bitrix24.ru/crm/type/1046/details/3/) `ИСХ-T416_3`; [incoming ID 5](https://b24-aug0be.bitrix24.ru/crm/type/1046/details/5/) `ВХ-T416_5`; [outgoing ID 7](https://b24-aug0be.bitrix24.ru/crm/type/1046/details/7/) `ИСХ-T416_7`. The robots created numbers on new IDs 5 and 7. Numbers on earlier IDs 1 and 3 were normalized manually. Editing the subject of ID 7 left its registration number unchanged. `Доступно для всех: Нет` was observed on the test records checked.

When creating correspondence, check required fields and save once. Open the saved card, wait for the robot if needed, then reload and read `Регистрационный номер`. If it remains empty, report the saved card link and the missing number; do not generate one yourself or retry creation blindly. Check that the chosen project and contract links open the intended objects. For an existing record, preserve its number unless the user explicitly asks to correct it.

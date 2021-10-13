# 4me-step-requests-create

This [4me](https://4me.com) step creates a new 4me [request](https://help.4me.com/help/request/).
It sets an output, `request`, containing the created request.

## Example output `request`

```json
{
  "addressed": false,
  "agile_board": null,
  "agile_board_column": null,
  "agile_board_column_position": null,
  "assignment_count": 0,
  "attachments": [],
  "category": "incident",
  "change": null,
  "ci": null,
  "ci_id": null,
  "completed_at": null,
  "completion_reason": null,
  "created_at": "2021-10-13T13:36:43-05:00",
  "created_by": {
    "account": {
      "id": "widget",
      "name": "Widget International"
    },
    "id": 6,
    "name": "Howard Tanner",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1BlcnNvbi82"
  },
  "custom_data": null,
  "custom_fields": null,
  "desired_completion_at": null,
  "downtime_end_at": null,
  "downtime_start_at": null,
  "grouped_into": null,
  "grouping": "none",
  "id": 80327,
  "impact": "high",
  "knowledge_article": null,
  "major_incident_status": null,
  "member": null,
  "new_assignment": true,
  "next_target_at": "best_effort",
  "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1JlcS84MDMyNw",
  "organization": {
    "account": {
      "id": "widget",
      "name": "Widget International"
    },
    "id": 52,
    "name": "Widget Data Center, External IT",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL09yZ2FuaXphdGlvbi81Mg"
  },
  "planned_effort": null,
  "problem": null,
  "project": null,
  "reopen_count": 0,
  "requested_by": {
    "account": {
      "id": "widget",
      "name": "Widget International"
    },
    "id": 6,
    "name": "Howard Tanner",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1BlcnNvbi82"
  },
  "requested_for": {
    "account": {
      "id": "widget",
      "name": "Widget International"
    },
    "id": 6,
    "name": "Howard Tanner",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1BlcnNvbi82"
  },
  "requester_resolution_target_at": null,
  "resolution_target_at": null,
  "response_target_at": null,
  "reviewed": false,
  "satisfaction": null,
  "service_instance": {
    "account": {
      "id": "wdc",
      "name": "Widget Data Center"
    },
    "id": 72,
    "localized_name": "Email (Exchange) Europe",
    "name": "Email (Exchange) Europe",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1NlcnZpY2VJbnN0YW5jZS83Mg"
  },
  "source": "4me-sdk-ruby/2.0.2",
  "sourceID": null,
  "status": "assigned",
  "subject": "First Demo Request",
  "supplier": null,
  "supplier_requestID": null,
  "task": null,
  "team": {
    "account": {
      "id": "wdc",
      "name": "Widget Data Center"
    },
    "id": 17,
    "name": "Windows Servers",
    "nodeID": "ZGVtbzExMTgwMS4yMTA5MjkxNjU1MzJANG1lLWRlbW8uY29tL1RlYW0vMTc"
  },
  "template": null,
  "updated_at": "2021-10-13T13:36:43-05:00",
  "urgent": false,
  "waiting_until": null
}
```

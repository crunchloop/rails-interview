import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.selectedByList = new Map()
  }

  toggleSelected(event) {
    const checkbox = event.target
    const todoListId = checkbox.dataset.todoListId
    const itemId = Number(checkbox.dataset.itemId)

    if (!this.selectedByList.has(todoListId)) this.selectedByList.set(todoListId, new Set())
    const set = this.selectedByList.get(todoListId)

    if (checkbox.checked) set.add(itemId)
    else set.delete(itemId)
  }

  async runBulkAction(event) {
    const select = event.target
    const actionName = select.value
    if (!actionName) return

    const todoListId = select.dataset.todoListId
    const selected = Array.from(this.selectedByList.get(todoListId) || [])

    // For 'all' actions, selected items are ignored by the backend

    select.disabled = true

    const res = await this.api(`/api/todolists/${todoListId}/bulk_actions`, {
      method: "POST",
      body: {
        action_name: actionName,
        item_ids: selected,
      },
    })

    select.disabled = false
    select.value = ""

    if (!res.ok) {
      alert(`Could not start bulk action (HTTP ${res.status})`)
      return
    }
  }

  async toggleItem(event) {
    const checkbox = event.target
    const itemId = checkbox.dataset.itemId
    const todoListId = checkbox.dataset.todoListId
    const nextStatus = checkbox.checked ? "closed" : "active"

    const res = await this.api(`/api/todolists/${todoListId}/todo_list_items/${itemId}`, {
      method: "PATCH",
      body: {
        todo_list_item: { status: nextStatus },
      },
    })

    if (!res.ok) {
      checkbox.checked = !checkbox.checked
      alert(`Could not update item (HTTP ${res.status})`)
      return
    }
  }

  async deleteItem(event) {
    const btn = event.target.closest("[data-item-delete]")
    const itemId = btn.dataset.itemId
    const todoListId = btn.dataset.todoListId

    const res = await this.api(`/api/todolists/${todoListId}/todo_list_items/${itemId}`, {
      method: "DELETE",
    })

    if (!res.ok) {
      alert(`Could not delete item (HTTP ${res.status})`)
      return
    }
  }

  async createItem(event) {
    if (event.key !== "Enter") return

    const input = event.target
    const todoListId = input.dataset.todoListId
    const description = input.value.trim()
    if (!description) return

    input.disabled = true

    const res = await this.api(`/api/todolists/${todoListId}/todo_list_items`, {
      method: "POST",
      body: {
        todo_list_item: { description, status: "active" },
      },
    })

    input.disabled = false

    if (!res.ok) {
      alert(`Could not create item (HTTP ${res.status})`)
      return
    }

    input.value = ""
  }

  async editItemDescription(event) {
    const input = event.target
    const itemId = input.dataset.itemId
    const todoListId = input.dataset.todoListId
    const description = input.value.trim()

    const res = await this.api(`/api/todolists/${todoListId}/todo_list_items/${itemId}`, {
      method: "PATCH",
      body: { todo_list_item: { description } },
    })

    if (!res.ok) {
      alert(`Could not update item (HTTP ${res.status})`)
      return
    }
  }

  async editTodoListName(event) {
    const input = event.target
    const todoListId = input.dataset.todoListId
    const name = input.value.trim()

    const res = await this.api(`/api/todolists/${todoListId}`, {
      method: "PATCH",
      body: { todo_list: { name } },
    })

    if (!res.ok) {
      alert(`Could not update list (HTTP ${res.status})`)
      return
    }
  }

  async api(url, { method, body } = {}) {
    const headers = {
      Accept: "application/json",
      "Content-Type": "application/json",
    }

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) headers["X-CSRF-Token"] = token

    return fetch(url, {
      method,
      headers,
      credentials: "same-origin",
      body: body ? JSON.stringify(body) : undefined,
    })
  }

}


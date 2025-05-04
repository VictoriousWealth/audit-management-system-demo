// Append the new row
$("#items-table tbody").append(`
    <tr>
      <td><%= j @item.name %></td>
      <td><%= j @item.description %></td>
    </tr>
  `);
  
  // Close the modal
  const modal = bootstrap.Modal.getInstance(document.getElementById('itemModal'));
  modal.hide();
  
  // Optionally reset the form
  $("#new_item_form")[0].reset();
  
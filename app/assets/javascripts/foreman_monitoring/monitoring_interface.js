$(document).on('click', '.interface_monitoring', function () {
  var confirmed = confirm_flag_change(
    this,
    '.interface_monitoring',
    __('Another interface is already set for monitoring. Are you sure you want to use this one instead?')
  );
  if (confirmed === false) return false;

  $('#interfaceForms .interface_monitoring:checked').prop('checked', false);
  return true;
});

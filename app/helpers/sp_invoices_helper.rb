module SpInvoicesHelper
  def sp_invoice_status_label(status)
    case status
    when "awaiting invoice"
      content_tag(:span, status.titleize, class: 'label label-orange')
    when "invoice received"
      content_tag(:span, status.titleize, class: 'label label-green')
    when "viewed"
      content_tag(:span, status.titleize, class: 'label label-grey')
    when "processed"
      content_tag(:span, status.titleize, class: 'label label-blue')
    else
      content_tag(:span, status, class: 'label')
    end
  end

  def job_sp_invoiced_status(job)
    if job.sp_invoice
      link_to sp_invoice_status_label(job.sp_invoice.status), edit_sp_invoice_path(job.sp_invoice)
    else
      content_tag(:span, "Awaiting Invoice", class: "label label-warning") if job.status == 'complete'
    end
  end

  def new_sp_invoices_count
    SpInvoice.where(status: 'invoice received').count
  end

  def new_sp_invoices_label(new_sp_invoices_count)
    content_tag(:span, new_sp_invoices_count, class: 'label label-satgreen')
  end

  def new_sp_invoices_label_small(new_sp_invoices_count)
    content_tag(:span, "#{new_sp_invoices_count} Received", class: 'label label-satgreen label-small', style: "margin-left: 3px;") if new_sp_invoices_count > 0
  end
end

export interface Job {
  id: string;
  ticket_id: string;
  module: string;
  status: string;

  target_host: string;
  target_port: number;
  connection_method: string;

  os_type: string;
  software_name: string;
  software_version?: string;

  requested_by?: string;
  justification?: string;

  current_plan_id?: string | null;
  operator_review_required?: boolean;
  review_reason?: string | null;
  notes?: string | null;
  trace_id?: string | null;

  created_at: string;
  updated_at: string;
}

export interface JobListResponse {
  items: Job[];
  total: number;
}
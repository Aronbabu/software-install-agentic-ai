import { api } from "./client";

export const getJob = async (
  jobId: string
) => {

  const response =
    await api.get(
      `/jobs/${jobId}`
    );

  return response.data;
};

export const getJobProgress = async (
  jobId: string
) => {

  const response =
    await api.get(
      `/jobs/${jobId}/progress`
    );

  return response.data;
};

export const resolveJobReview = async (
  jobId: string,
  payload: {
    resolution_type: "REUSE_PLAN" | "USE_SOP" | "APPROVE_AI_PLAN" | "DEFER_TO_MANUAL";
    selected_plan_id?: string | null;
    selected_sop_id?: string | null;
    operator_notes?: string | null;
    auto_queue_execution?: boolean;
  }
) => {
  const response = await api.post(`/jobs/${jobId}/resolve-review`, payload);
  return response.data;
};
import { FC } from 'react';
import { Button } from '@mui/material';

import { saveAllGrades } from 'course/assessment/submission/actions/answers';
import { workflowStates } from 'course/assessment/submission/constants';
import {
  getExperiencePoints,
  getQuestionWithGrades,
} from 'course/assessment/submission/selectors/grading';
import { getSubmissionFlags } from 'course/assessment/submission/selectors/submissionFlags';
import { getSubmission } from 'course/assessment/submission/selectors/submissions';
import translations from 'course/assessment/submission/translations';
import { getSubmissionId } from 'lib/helpers/url-helpers';
import { useAppDispatch, useAppSelector } from 'lib/hooks/store';
import useTranslation from 'lib/hooks/useTranslation';

const SaveGradeButton: FC = () => {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();

  const submission = useAppSelector(getSubmission);
  const submissionFlags = useAppSelector(getSubmissionFlags);
  const expPoints = useAppSelector(getExperiencePoints);
  const questionWithGrades = useAppSelector(getQuestionWithGrades);

  const submissionId = getSubmissionId();

  const { graderView, workflowState } = submission;
  const { isSaving } = submissionFlags;

  const attempting = workflowState === workflowStates.Attempting;
  const published = workflowState === workflowStates.Published;

  const handleSaveAllGrades = (): void => {
    dispatch(
      saveAllGrades(
        submissionId,
        Object.values(questionWithGrades),
        expPoints,
        published,
      ),
    );
  };

  return (
    graderView &&
    !attempting && (
      <Button
        className="mb-2 mr-2"
        color="primary"
        disabled={isSaving}
        onClick={handleSaveAllGrades}
        variant="contained"
      >
        {t(translations.saveGrade)}
      </Button>
    )
  );
};

export default SaveGradeButton;
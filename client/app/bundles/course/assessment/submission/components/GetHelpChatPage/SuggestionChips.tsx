import { FC } from 'react';
import { Button } from '@mui/material';

import { SYNC_STATUS } from 'lib/constants/sharedConstants';
import { getSubmissionId } from 'lib/helpers/url-helpers';
import { useAppDispatch, useAppSelector } from 'lib/hooks/store';
import useTranslation from 'lib/hooks/useTranslation';

import { generateLiveFeedback } from '../../actions/answers';
import { sendPromptFromStudent } from '../../reducers/liveFeedbackChats';
import { getLiveFeedbackChatsForAnswerId } from '../../selectors/liveFeedbackChats';
import translations from '../../translations';
import { Suggestion } from '../../types';

interface SuggestionChipsProps {
  answerId: number;
  syncStatus: keyof typeof SYNC_STATUS;
}

const SuggestionChips: FC<SuggestionChipsProps> = (props) => {
  const { answerId, syncStatus } = props;

  const { t } = useTranslation();
  const dispatch = useAppDispatch();

  const submissionId = getSubmissionId();

  const liveFeedbackChatsForAnswer = useAppSelector((state) =>
    getLiveFeedbackChatsForAnswerId(state, answerId),
  );
  const isCurrentThreadExpired =
    liveFeedbackChatsForAnswer?.isCurrentThreadExpired;
  const currentThreadId = liveFeedbackChatsForAnswer?.currentThreadId;

  const suggestions = liveFeedbackChatsForAnswer?.suggestions ?? [];

  const sendHelpRequest = (suggestion: Suggestion): void => {
    const message = t({
      id: suggestion.id,
      defaultMessage: suggestion.defaultMessage,
    });

    dispatch(sendPromptFromStudent({ answerId, message }));
    dispatch(
      generateLiveFeedback({
        submissionId,
        answerId,
        threadId: currentThreadId,
        message,
        errorMessage: t(translations.requestFailure),
        options: suggestions.map((option) => option.index),
        optionId: suggestion.index,
      }),
    );
  };

  return (
    <div className="scrollbar-hidden absolute bottom-full flex px-1.5 py-0.5 gap-2 w-full overflow-x-auto">
      {suggestions.map((suggestion) => (
        <Button
          key={suggestion.id}
          className="bg-white text-xl shrink-0"
          disabled={syncStatus === SYNC_STATUS.Failed || isCurrentThreadExpired}
          onClick={() => sendHelpRequest(suggestion)}
          variant="outlined"
        >
          {t({
            id: suggestion.id,
            defaultMessage: suggestion.defaultMessage,
          })}
        </Button>
      ))}
    </div>
  );
};

export default SuggestionChips;

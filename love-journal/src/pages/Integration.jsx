import { JournalPrompt, SectionDivider, ScaleInput } from '../components/JournalPrompt'

function IntegrationHub({ hubId, title, store }) {
  return (
    <div className="mb-10">
      <h3 className="font-serif text-xl font-semibold text-text-main mb-1">{title}</h3>
      <div className="w-12 h-px bg-gold/40 mb-4" />

      <h4 className="font-serif text-base font-medium text-text-main mb-2">Pattern Recognition</h4>
      <JournalPrompt id={`${hubId}-love`} label="About how love works" store={store} />
      <JournalPrompt id={`${hubId}-resist`} label="About how I resist or receive" store={store} />
      <JournalPrompt id={`${hubId}-desires`} label="About what my desires are really pointing to" store={store} />

      <h4 className="font-serif text-base font-medium text-text-main mt-6 mb-2">Growth Evidence</h4>
      <JournalPrompt id={`${hubId}-choices`} label="Different choices I made" store={store} />
      <JournalPrompt id={`${hubId}-boundaries`} label="New boundaries or forms of self-kindness" store={store} />
      <JournalPrompt id={`${hubId}-timing`} label="Moments where I trusted timing more than before" store={store} />

      <h4 className="font-serif text-base font-medium text-text-main mt-6 mb-2">Current Questions</h4>
      <JournalPrompt id={`${hubId}-questions`} label="Questions I am still living with (that do not need answers yet)" store={store} />

      <h4 className="font-serif text-base font-medium text-text-main mt-6 mb-2">Next Gentle Edge</h4>
      <JournalPrompt id={`${hubId}-edge`} label="One small, specific thing I am willing to experiment with" store={store} />
    </div>
  )
}

export function Integration({ store }) {
  return (
    <div className="animate-fade-in px-4 pb-28">
      {/* Part III - Integration Hubs */}
      <SectionDivider
        title="Integration Hubs"
        subtitle="Pause points after every few chapters to recognize patterns and growth."
        icon="◈"
      />

      <IntegrationHub hubId="hub1" title="Hub 1 — After Chapters 0–3" store={store} />
      <IntegrationHub hubId="hub2" title="Hub 2 — After Chapters 4–7" store={store} />
      <IntegrationHub hubId="hub3" title="Hub 3 — After Chapters 8–12" store={store} />

      {/* Part IV - Shadow & Depth */}
      <SectionDivider
        title="Shadow & Depth Work"
        subtitle="Use these whenever you hit something tender."
        icon="◐"
      />

      <JournalPrompt id="shadow-avoiding" label="What I am avoiding" store={store} />
      <JournalPrompt id="shadow-afraid" label="What I am afraid might happen if I fully received what I desire" store={store} />
      <JournalPrompt id="shadow-protecting" label="What my resistance might be wisely protecting" store={store} />
      <JournalPrompt
        id="shadow-lovehonor"
        label="How could Love honor this protection and still invite me forward?"
        store={store}
      />

      {/* Part V - Closing */}
      <SectionDivider
        title="Journey Review & Closing"
        subtitle="Return to your Pre-Journey Self-Assessment. What has shifted?"
        icon="✧"
      />

      <ScaleInput id="close-scale-life" label="My sense that life is fundamentally on my side (now)" store={store} />
      <ScaleInput id="close-scale-timing" label="My ability to trust timing (now)" store={store} />
      <ScaleInput id="close-scale-tenderness" label="My tenderness toward my own resistance (now)" store={store} />
      <ScaleInput id="close-scale-desire" label="My comfort with desire (now)" store={store} />
      <ScaleInput id="close-scale-connection" label="My felt connection to something larger than me (now)" store={store} />

      <JournalPrompt
        id="close-story"
        label="Journey Reflection"
        hint="The story I would tell now about my relationship with the Universe / Law of Love is…"
        store={store}
      />

      <h3 className="font-serif text-lg font-semibold text-text-main mt-8 mb-3">Final Wisdom Distillation</h3>
      <p className="text-text-muted text-sm mb-4 italic">List 5–10 core truths you want to carry forward:</p>
      {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(n => (
        <JournalPrompt key={n} id={`close-truth${n}`} label={`Truth ${n}`} store={store} multiline={false} />
      ))}

      {/* Future Self Letters */}
      <SectionDivider
        title="Future Self Letters"
        subtitle="Bless your future self with tenderness, not demands."
        icon="❋"
      />

      <JournalPrompt id="letter-1mo" label="A letter to myself 1 month from now" store={store} />
      <JournalPrompt id="letter-6mo" label="A letter to myself 6 months from now" store={store} />
      <JournalPrompt id="letter-1yr" label="A letter to myself 1 year from now" store={store} />

      {/* Gratitude & Completion */}
      <SectionDivider
        title="Gratitude & Completion"
        subtitle="You can mark completion with a tiny ritual: a candle, a walk, a song, a deep breath."
        icon="✦"
      />

      <JournalPrompt id="close-gratitude-self" label="Gratitude for the parts of you that showed up" store={store} />
      <JournalPrompt id="close-gratitude-support" label="Gratitude for any unseen support you felt" store={store} />
      <JournalPrompt id="close-gratitude-mystery" label="Gratitude for the courage to be in relationship with Mystery" store={store} />

      {/* Part VI - Check-Ins */}
      <SectionDivider
        title="Continuing Check-Ins"
        subtitle="Use the same questions at each interval."
        icon="◯"
      />

      {['1 Week', '1 Month', '3 Months', '6 Months', '1 Year'].map((interval) => {
        const key = interval.toLowerCase().replace(/\s/g, '')
        return (
          <div key={key} className="mb-10">
            <h3 className="font-serif text-lg font-semibold text-text-main mb-3">Check-In: {interval}</h3>
            <JournalPrompt
              id={`checkin-${key}-love`}
              label="3 ways I can see the Law of Love at work in my life"
              store={store}
            />
            <JournalPrompt
              id={`checkin-${key}-possible`}
              label="What feels more possible now than it did before?"
              store={store}
            />
            <JournalPrompt
              id={`checkin-${key}-tender`}
              label="One area where I still feel tender — and how I can bring more kindness, not pressure"
              store={store}
            />
            <JournalPrompt
              id={`checkin-${key}-nextstep`}
              label="What tiny next step feels loving, realistic, and meaningful?"
              store={store}
            />
          </div>
        )
      })}
    </div>
  )
}

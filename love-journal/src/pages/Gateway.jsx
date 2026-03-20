import { JournalPrompt, JournalCheckbox, ScaleInput, SectionDivider } from '../components/JournalPrompt'

export function Gateway({ store }) {
  return (
    <div className="animate-fade-in px-4 pb-28">
      {/* 1. Why This Book Now */}
      <SectionDivider
        title="Why This Book Now?"
        subtitle="What called you here, at this exact moment in your life?"
        icon="✦"
      />

      <JournalPrompt
        id="gw-called"
        label="What called you here?"
        hint="What drew you to this book and this journal at this exact moment in your life?"
        placeholder="I am reading this book now because…"
        store={store}
      />

      <JournalPrompt
        id="gw-tender"
        label="What is tender or alive right now?"
        hint="Name 3–5 themes currently active in your life (relationships, money, purpose, healing, creativity, belonging)."
        store={store}
      />

      <JournalPrompt
        id="gw-theme1"
        label="Theme 1"
        store={store}
        multiline={false}
      />
      <JournalPrompt
        id="gw-theme2"
        label="Theme 2"
        store={store}
        multiline={false}
      />
      <JournalPrompt
        id="gw-theme3"
        label="Theme 3"
        store={store}
        multiline={false}
      />
      <JournalPrompt
        id="gw-theme4"
        label="Theme 4 (optional)"
        store={store}
        multiline={false}
      />
      <JournalPrompt
        id="gw-theme5"
        label="Theme 5 (optional)"
        store={store}
        multiline={false}
      />

      <JournalPrompt
        id="gw-hoping"
        label="What are you secretly hoping will change?"
        hint="Let yourself be honest and specific."
        placeholder="If this book and journal 'worked' for me, my life would feel different in these ways…"
        store={store}
      />

      {/* 2. Personal Context Snapshot */}
      <SectionDivider
        title="Personal Context Snapshot"
        subtitle="Use this to locate yourself in your current life."
        icon="◯"
      />

      <JournalPrompt
        id="gw-relationships"
        label="Relationships"
        hint="How are you relating to partners, friends, family, community right now?"
        store={store}
      />

      <JournalPrompt
        id="gw-work"
        label="Work / Calling / Study"
        hint="What are you giving your energy to most days? How does it feel in your body?"
        store={store}
      />

      <JournalPrompt
        id="gw-inner"
        label="Inner Landscape"
        hint="What is the general weather inside you lately (stormy, foggy, bright, mixed, numb, quietly hopeful)?"
        store={store}
      />

      <JournalPrompt
        id="gw-body"
        label="Body & Nervous System"
        hint="How does your body feel most of the time? What does stress look like for you? What does safety feel like for you?"
        store={store}
      />

      <JournalPrompt
        id="gw-spiritual"
        label="Spiritual / Meaning Orientation"
        hint='How do you currently imagine "the universe," "life," "God," "Love," or whatever language feels right?'
        store={store}
      />

      {/* 3. Learning Intentions */}
      <SectionDivider
        title="Learning Intentions"
        subtitle="You do not need to impress this book or this journal. Your intentions can be humble, even hesitant."
        icon="❋"
      />

      <JournalPrompt
        id="gw-understand"
        label="I want to understand…"
        store={store}
      />
      <JournalPrompt
        id="gw-feel"
        label="I want to feel more…"
        store={store}
      />
      <JournalPrompt
        id="gw-relate"
        label="I want to relate differently to…"
        store={store}
      />
      <JournalPrompt
        id="gw-remember"
        label="I want to remember that…"
        store={store}
      />

      {/* 4. Reading Rhythm */}
      <SectionDivider
        title="Reading Rhythm & Self-Agreement"
        subtitle="How do you want to move through this book?"
        icon="◈"
      />

      <div className="glass rounded-xl p-4 mb-6 space-y-1">
        <JournalCheckbox id="gw-pace-slow" label="A slow sip (one chapter per week, lots of integration)" store={store} />
        <JournalCheckbox id="gw-pace-gentle" label="A gentle middle (1–2 chapters per week)" store={store} />
        <JournalCheckbox id="gw-pace-immersive" label="An immersive dive (multiple chapters in a few days)" store={store} />
        <JournalCheckbox id="gw-pace-nonlinear" label="Non-linear (I will follow what calls me most)" store={store} />
      </div>

      <JournalPrompt
        id="gw-when"
        label="When and where will you usually read?"
        hint="Time of day, locations, rituals (tea, music, blanket, candle)."
        store={store}
      />

      <div className="glass rounded-2xl p-5 mb-6">
        <p className="font-serif text-base text-text-main leading-relaxed italic mb-4">
          "I agree to move through this book and journal at the pace my body and life can genuinely hold. I do not have to 'keep up.' I am allowed to pause, repeat, skip ahead, or return. I choose curiosity over perfection."
        </p>
        <JournalPrompt
          id="gw-agreement"
          label="Your version (sign or initial if that feels grounding)"
          store={store}
        />
      </div>

      {/* 5. Pre-Journey Self-Assessment */}
      <SectionDivider
        title="Pre-Journey Self-Assessment"
        subtitle="On a scale of 1–10, honestly, without judgment."
        icon="✧"
      />

      <ScaleInput id="gw-scale-life" label="My sense that life is fundamentally on my side" store={store} />
      <ScaleInput id="gw-scale-timing" label="My ability to trust timing (even when I do not understand it)" store={store} />
      <ScaleInput id="gw-scale-tenderness" label="My tenderness toward my own resistance" store={store} />
      <ScaleInput id="gw-scale-desire" label="My comfort with desire (naming what I truly want)" store={store} />
      <ScaleInput id="gw-scale-connection" label="My felt connection to something larger than me" store={store} />

      <JournalPrompt
        id="gw-resourced"
        label="What feels most resourced in me right now is…"
        store={store}
      />
      <JournalPrompt
        id="gw-fragile"
        label="What feels most fragile or afraid right now is…"
        store={store}
      />
      <JournalPrompt
        id="gw-lovespeaks"
        label="If Love could speak to me at the start of this journey, it might say…"
        store={store}
      />
    </div>
  )
}

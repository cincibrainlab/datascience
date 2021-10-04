---
title: How do you teach an absolute beginner to read and interpret an EEG paper?
date: 2021-10-04T12:38:27.690Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
At any given time our lab has a mix of old and new research coordinators, students (from high school through postdocs), research associates, and interdisciplinary faculty. This guide is an attempt to separate the expertise of reading an EEG paper from the experience. In my opinion, there is a stunning amount of raw brain power in many laboratories. According to cognitive ease theory, the most salient and approachable content will attract the most brainpower. 

This post is not necessarily for you to learn how to read an EEG paper. Instead, it is a tool to help you help someone else to learn how to read an EEG paper. How much more effective could our labs run if every level of our lab had a great grasp on the same concepts? 

Data scientists know that the majority of our days are spent reorganizing data so that high-performance computers can use it. Why not work on making content more accessible to people who each carry a [petaflop of computational power ](http://webhome.phy.duke.edu/~hsg/363/table-images/brain-vs-computer.html#:~:text=But%20a%20rough%20estimate%20based,trillion%20(1015)%20logical%20operations)(at an impressive 15 watts)? 

##By the time you are done reading this post you will learn:

* The measure of interest in the majority of EEG papers is either the amplitude or phase of a signal. 
* The amount of interpretation ("what") you can get from EEG data is based on 1) how the data was collected, 2) how the data was processed, 3) who the data was collected on?
* A novel or complex EEG measure is limited by the underlying raw data.
* The "why" behind EEG findings remains a matter of opinion. The strength of that opinion is based on the previous two points.

### How do you introduce EEG?

For many learners, the first exposure to a new topic is a critical juncture where they may either want to learn more or less. In a lab, this may be the moment when a student says "that's my P.I.s interest" versus "that's interesting to me".

### Start with the concrete

The two most common approaches to introducing EEG either starts discussing the brain or electricity. In my experience, this rarely "hits home". Explaining, for example, that electrical impulses in the brain can be measured and these measurements can indirectly give us insights on how human behavior works is intuitive to the lifelong researcher but rarely captures the interest of an early learner. Despite our higher cognition, human beings are still drawn towards things that are concrete - and able to be handled by our five senses. 

### Using the five senses

Instead, if you are introducing an event-related paradigm start with either playing or showing the stimulus itself. If you are working on resting data ask the learner to close their eyes and pay attention to what they are thinking or feeling. This is an important mental alignment between what you are measuring and what you are doing. 

### Avoid the temptation to discuss oscillations early on

Discussing the presence and differences of delta, theta, alpha, etc often seems to be an early part of explaining EEG. I have observed that people, even scientists, have an initial mental aversion to discussing sine functions. I also believe the assumption that all brain activity is periodic and sinusoidal in nature does not truly capture the direction that the field is heading. 

### Focus first on the actual, physical signal itself

Starting with the actual physical quantity measured by EEG removes any of the residual mystery around the technology. Again, rather than delve immediately into electricity, I like to point out that the EEG signal is measuring a series of heights over time. A height must always be measured relative to something, for a person that is the ground, but for an EEG signal it is relative to a reference point. Height is actually a fairly accurate analog to electrical potential (volts).

Signal processing is not a typical educational topic across any level of education. For many learners a signal is mystery. It is important to explain that we are measuring a "series of heights over time" to dispel any notion that the EEG signal is some sort of  "always on" continuous flow of information. It is also important to stress early on that the height is always measured compared to reference as a student may have the misconception that the brain is "emitting" a signal that we are capturing, similar to other types of biological assays.

### Assess understanding and interest of your concrete explanation of EEG

It is enjoyable to watch the "ah ha!" moment in a learner when they connect the physical activity with the concrete signal we are measuring. I also explain that [active recall](https://en.wikipedia.org/wiki/Active_recall#:~:text=Active%20recall%20is%20a%20principle,memory%20during%20the%20learning%20process.&text=Active%20recall%20exploits%20the%20psychological,in%20consolidating%20long%2Dterm%20memory.) is the most efficient form of learning and will probe with questions on their understanding. If you have this reaction, it is a clear signal to keep moving forward, if not, I would retrace your steps.

## In Part 2 we will discuss further how to teach a pragmatic approach to reading an EEG paper